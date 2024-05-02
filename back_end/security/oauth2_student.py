from fastapi.security import OAuth2PasswordBearer
from fastapi import status, Depends, HTTPException
from typing import Annotated
from security import jwt_auth

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/student_auth/login")

async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    return jwt_auth.verify_access_token(token, credentials_exception)