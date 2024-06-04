from fastapi import APIRouter, Depends, status, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
import schemas
from typing import Annotated
import pydantic
from bson.objectid import ObjectId
from security import hashing, jwt_auth
from database.lecturer_auth_profile_db import lecturer_auth_collection

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
async def lecturer_forgot_pwd(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    pass