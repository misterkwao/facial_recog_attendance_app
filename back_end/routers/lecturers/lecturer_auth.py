from datetime import datetime, timedelta
from email.mime.text import MIMEText
import random
import smtplib
from dotenv import dotenv_values
from fastapi import APIRouter, Depends, status, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
import schemas
from typing import Annotated
import pydantic
from bson.objectid import ObjectId
from security import hashing, jwt_auth
from database.lecturer_auth_profile_db import lecturer_auth_collection
config = dotenv_values('.env')

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Lecturer Auth"]
)


@router.post('/lecturer_auth/login')
def lecturer_login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    data = lecturer_auth_collection.find_one({"lecturer_email":form_data.username})
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Credentials")
    else:
        if hashing.Hash.verify_hashed_password(form_data.password, data["password"]):
            access_token = jwt_auth.create_access_token(data={"sub":str(data["_id"]),"sub_name":data["lecturer_name"],"sub_role":'lecturer'})
            return schemas.Token(access_token=access_token,token_type="bearer")
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Credentials")
        
@router.post('/lecturer_auth/forgot-password')
async def lecturer_forgot_pwd(request:schemas.forgetPwd):
    
    def send_email(subject, body, sender, recipients, password):
        try:
            msg = MIMEText(body)
            msg['Subject'] = subject
            msg['From'] = sender
            msg['To'] = recipients

            with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp_server:
                smtp_server.login(sender, password)
                smtp_server.sendmail(sender, recipients, msg.as_string())

        except smtplib.SMTPException as e:
            print(f"SMTP error occurred: {e}")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to send email. Please try again later.")

        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected error occurred. Please try again later.")

    data = lecturer_auth_collection.find_one({"student_email":request.email})
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
            state = lecturer_auth_collection.find_one_and_update({"_id": ObjectId(data["_id"])},{ '$set': { "hashed_reset_pin" : hashing.Hash.get_pwd_hashed(str(random_number)),"reset_expire_time":new_time,"updatedAt": datetime.now()}})

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
         
@router.post('/lecturer_auth/verify-code')
async def verify_code(reset_id:str,request:schemas.VerifyCode):
     # We find the document we need to change the password with the code from the user
    data = lecturer_auth_collection.find_one({"_id": ObjectId(reset_id)})
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Something went wrong')
    else:
        if hashing.Hash.verify_hashed_password(str(request.code), data["hashed_reset_pin"]) and not (datetime.now()> data["reset_expire_time"]):
            return {
                    "detail": "Code is valid",
                    "reset_id": data["_id"]
                    }
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Code is invalid or has expired')
        
@router.patch('/lecturer_auth/reset-password')
async def change_password(reset_id:str,request:schemas.ResetPassword):
      hashed_password = hashing.Hash.get_pwd_hashed(request.new_password)
      try:
         state = lecturer_auth_collection.find_one_and_update({"_id": ObjectId(reset_id)},{ '$set': { "password" : hashed_password,"hashed_reset_pin":None,"reset_expire_time":None,"updatedAt": datetime.now()}}) 
         return {
              "detail": "Password reset successful"
         } 
      except Exception as e:
           raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
         

         
