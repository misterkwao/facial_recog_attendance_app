from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Hash():
    def get_pwd_hashed(password):
        return pwd_context.hash(password)
    

    def verify_hashed_password(plain_password, hashed_password):
        return pwd_context.verify(plain_password, hashed_password)