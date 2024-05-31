from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import  dotenv_values
from pymongo.mongo_client import MongoClient
from routers.admin import admin_auth, admin_ctrl
from routers.lecturers import lecturer_ctrl, lecturer_auth
from routers.students import students_ctrl, students_auth
from security import rate_limit

app = FastAPI()
origins = [
    "http://localhost",
    "http://localhost:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# config = dotenv_values('.env')

# client = MongoClient(config['MONGO_URI'])
# try:
#     client.admin.command('ping')
#     print("Pinged your deployment. You successfully connected to MongoDB!")
# except Exception as e:
#     print(e)
# app.add_middleware(rate_limit.AdvancedMiddleware)
@app.get('/')
def home_page():
    return 'Welcome to Facial Recognition'


# Routers
app.include_router(admin_auth.router)
app.include_router(admin_ctrl.router)
app.include_router(students_auth.router)
app.include_router(students_ctrl.router)
app.include_router(lecturer_auth.router)
app.include_router(lecturer_ctrl.router)
