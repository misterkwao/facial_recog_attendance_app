from fastapi import APIRouter,status,Depends,HTTPException, Response
from fastapi.security import OAuth2PasswordRequestForm
from typing import Annotated
from database.admin_auth_profile_db import admin_auth_collection, admin_profile_collection
import schemas, models
from security import hashing, jwt_auth
import pydantic
from bson.objectid import ObjectId
from datetime import datetime


pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Admin Auth"]
)

@router.post('/admin_auth/signup')
async def create_admin(request: schemas.AdminSignup):
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
           access_token = jwt_auth.create_access_token(data={"sub":str(data["_id"]),"sub_name":data["username"]})
           return schemas.Token(access_token=access_token,token_type="bearer")   
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Credentials")
        
@router.post('/admin_auth/forgot-password')
async def admin_forgot_pwd(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    pass