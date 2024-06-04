from datetime import datetime, timedelta, timezone
from dotenv import  dotenv_values
from jose import JWTError, jwt
import schemas

config = dotenv_values('.env')

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=int(config['ACCESS_TOKEN_EXPIRE_MINUTES']))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, config['SECRET_KEY'], algorithm=config['ALGORITHM'])
    return encoded_jwt


def verify_access_token(token: str, credentials_exception):
    try:
        payload = jwt.decode(token, config['SECRET_KEY'], algorithms=[config['ALGORITHM']])
        user_id: str = payload.get("sub")
        user_name: str = payload.get("sub_name")
        user_role: str = payload.get("sub_role")
        if id is None:
            raise credentials_exception
        token_data = schemas.TokenData(user_id=user_id, user_name=user_name,user_role=user_role)
        return token_data
    except JWTError:
        raise credentials_exception