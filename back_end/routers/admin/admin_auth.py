from email.mime.text import MIMEText
import random
import smtplib
from dotenv import dotenv_values
from fastapi import APIRouter,status,Depends,HTTPException, Response
from fastapi.security import OAuth2PasswordRequestForm
from typing import Annotated
from database.admin_auth_profile_db import admin_auth_collection, admin_profile_collection
import schemas
from security import hashing, jwt_auth, oauth2_Admin
import pydantic
from bson.objectid import ObjectId
from datetime import datetime, timedelta

config = dotenv_values('.env')
pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Admin Auth"]
)

@router.post('/admin_auth/signup')
async def create_admin(request: schemas.AdminSignup, current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    # hash user password
    user_hashed_password = hashing.Hash.get_pwd_hashed(request.password)
   
    try:
        # Creating admin account with profile
        admin = admin_auth_collection.insert({
        "username": request.username,
        "email": request.email,
        "password": user_hashed_password,
        "createdAt": datetime.now()
    }) #This return user ID
        admin_profile_collection.insert({
            "owner": admin,
            "username": request.username,
            "createdAt": datetime.now()
        })

        return{
            "detail":"User created successfully"
        }
        
    except Exception as e:
        response = str(e)
        if "duplicate key error collection" in response:
           raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already is already registered")
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
          
    
@router.post('/admin_auth/login')
async def admin_login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    data = admin_auth_collection.find_one({"email":form_data.username})
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Credentials")
    else:
        if hashing.Hash.verify_hashed_password(form_data.password, data["password"]):
           access_token = jwt_auth.create_access_token(data={"sub":str(data["_id"]),"sub_name":data["username"],"sub_role":'admin'})
           return schemas.Token(access_token=access_token,token_type="bearer")   
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Credentials")
        
@router.post('/admin_auth/forgot-password')
async def admin_forgot_pwd(request:schemas.forgetPwd):
        
    def send_email(subject, body, sender, recipient, password):
        try:
            msg = MIMEText(body)
            msg['Subject'] = subject
            msg['From'] = sender
            msg['To'] = recipient

            with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp_server:
                smtp_server.login(sender, password)
                smtp_server.sendmail(sender, recipient, msg.as_string())
                

        except smtplib.SMTPException as e:
            print(f"SMTP error occurred: {e}")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to send email. Please try again later.")

        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected error occurred. Please try again later.")

    data = admin_auth_collection.find_one({"email":request.email})
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email does not exist")
    else:
         try:
            # Generate a random 5-digit number
            random_number = random.randint(10000, 99999)
            # Get the current date and time
            current_time = datetime.now()
            # Add 10 minutes to the current time
            new_time = current_time + timedelta(minutes=10)
            state = admin_auth_collection.find_one_and_update({"_id": ObjectId(data["_id"])},{ '$set': { "hashed_reset_pin" : hashing.Hash.get_pwd_hashed(str(random_number)),"reset_expire_time":new_time,"updatedAt": datetime.now()}})

            #email_
            subject = "Reset Password"
            body = f"Password reset request received. Please enter the code below in the pin field to reset your password\n\nCode: {random_number}\n\nThis code is only valid for 10 minutes\n\nPlease do not share your code"
            sender = config["EMAIL_ADDRESS"]
            recipients = request.email
            password = config["EMAIL_PASSWORD"]

            send_email(subject, body, sender, recipients, password)
            return {
                 "detail": "Email has been sent successfully",
                 "reset_id": data["_id"]
            }
         except Exception as e:
             raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="An unexpected error occurred, please try again later")
 
         
@router.post('/admin_auth/verify-code')
async def verify_code(reset_id:str,request:schemas.VerifyCode):
     # We find the document we need to change the password with the code from the user
    data = admin_auth_collection.find_one({"_id": ObjectId(reset_id)})
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Something went wrong')
    else:
        if hashing.Hash.verify_hashed_password(str(request.code), data["hashed_reset_pin"]) and not (datetime.now()> data["reset_expire_time"]):
            admin_auth_collection.find_one_and_update({"_id": ObjectId(reset_id)},{'$set':{"is_code_valid": True,"updatedAt": datetime.now()}})
            return {
                    "detail": "Code is valid",
                    "reset_id": data["_id"]
                    }
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Code is invalid or has expired')
        

@router.patch('/admin_auth/reset-password',status_code=200)
async def change_password(reset_id:str,response:Response,request:schemas.ResetPassword):
      hashed_password = hashing.Hash.get_pwd_hashed(request.new_password)
      try:
         data = admin_auth_collection.find_one({"_id": ObjectId(reset_id)})
         if data["is_code_valid"] == True:
            state = admin_auth_collection.find_one_and_update({"_id": ObjectId(reset_id)},{ '$set': { "password" : hashed_password,"is_code_valid": False,"hashed_reset_pin":None,"reset_expire_time":None,"updatedAt": datetime.now()}}) 
            return {
                "detail": "Password reset successful"
            }
         else:
             response.status_code = status.HTTP_400_BAD_REQUEST
             return {
                "detail": "Password reset failed"
            }
      except Exception as e:
           raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
         