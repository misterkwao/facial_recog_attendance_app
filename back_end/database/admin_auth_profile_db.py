# This file contains the admin auth collection and paired profile collection
# This done to add a layer of data hiding
from pymongo import MongoClient
import pymongo
from dotenv import  dotenv_values

config = dotenv_values('.env')

client = MongoClient(config['MONGO_URI'])
db = client.facerecog_db #name of database

def create_admin_auth_collection():
    try:
        db.create_collection("admin_auth")
    except Exception as e:
        return e
    
    db.command("collMod", "admin_auth", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["username", "email", "password"],
            "properties": {
                "username": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "email": {
                    "bsonType": "string",
                    "pattern": "^\\S+@\\S+\\.\\S+$",
                    "description": "must be a string and is required"
                },
                "password": {
                    "bsonType": "string",
                    "minLength":8,
                    "description": "must be a string and is required"
                },
                "is_code_valid":{
                    "bsonType": "bool",
                    "description": "must be a bool and is required"
                },
                "hashed_reset_pin":{
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "reset_expire_time":{
                    "bsonType": "date",
                    "description": "must be a string and is required"
                },
                "createdAt":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                },
                "updatedAt":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                }
            }
        }
    
    })

create_admin_auth_collection()
admin_auth_collection = db.admin_auth
admin_auth_collection.create_index([("email", pymongo.ASCENDING)], unique=True)

def create_admin_profile_collection():
    try:
        db.create_collection("admin_profile")
    except Exception as e:
        return e
    
    db.command("collMod", "admin_profile", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["username", "owner"],
            "properties": {
                "username": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "owner": {
                    "bsonType": "objectId",
                    "description": "must be a string and is required"
                },
                "createdAt":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                },
                "updatedAt":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                }
            }
        }
    
    })


create_admin_profile_collection()
admin_profile_collection = db.admin_profile
