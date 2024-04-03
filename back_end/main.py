from fastapi import FastAPI
from dotenv import  dotenv_values
from pymongo.mongo_client import MongoClient
from routers.admin import admin_auth, admin_ctrl
app = FastAPI()

config = dotenv_values('.env')

# client = MongoClient(config['MONGO_URI'])
# try:
#     client.admin.command('ping')
#     print("Pinged your deployment. You successfully connected to MongoDB!")
# except Exception as e:
#     print(e)

@app.get('/')
def home_page():
    return 'Welcome to Facial Recognition'

app.include_router(admin_auth.router)
app.include_router(admin_ctrl.router)