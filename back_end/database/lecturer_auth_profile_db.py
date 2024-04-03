# This file contains the lecturer auth collection and paired profile collection
# This done to add a layer of data hiding
from pymongo import MongoClient
import pymongo
from dotenv import  dotenv_values

config = dotenv_values('.env')

client = MongoClient(config['MONGO_URI'])
db = client.facerecog_db #name of database


def create_lecturer_auth_collection():
    try:
        db.create_collection("lecturer_auth")
    except Exception as e:
        return e
    
    db.command("collMod", "lecturer_auth", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["lecturer_name", "lecturer_email", "password"],
            "properties": {
                "lecturer_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "lecturer_email": {
                    "bsonType": "string",
                    "pattern": "^\\S+@\\S+\\.\\S+$",
                    "description": "must be a string and is required"
                },
                "password": {
                    "bsonType": "string",
                    "minLength":8,
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

create_lecturer_auth_collection()
lecturer_auth_collection = db.lecturer_auth
lecturer_auth_collection.create_index([("lecturer_email", pymongo.ASCENDING)], unique=True)


def create_lecturer_profile_collection():
    try:
        db.create_collection("lecturer_profile")
    except Exception as e:
        return e
    
    db.command("collMod", "lecturer_profile", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["lecturer_name", "owner", "allowed_courses"],
            "properties": {
                "lecturer_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "owner": {
                    "bsonType": "objectId",
                    "description": "must be a string and is required"
                },
                "allowed_courses":{
                    "bsonType": "array",
                    "minItems": 1,
                    "uniqueItems": True,
                    "additionalProperties": False,
                    "items":{
                        "bsonType": "object",
                        "required": ["level", "semester","course_title", "college", "department"],
                        "additionalProperties": False,
                        "description": "'items' must contain the stated fields.",
                        "properties":{
                            "level":{
                                "bsonType": "int",
                                "description":"must be the level of student to be lectured"
                            },
                            "semester":{
                                "bsonType": "int",
                                "description": "must be a integer and is required"
                            },
                            "course_title":{
                                "bsonType": "string",
                                "description": "must be a string and is required"
                            },
                            "college":{
                                "bsonType": "string",
                                "description": "must be a string and is required"
                            },
                            "department":{
                                "bsonType": "string",
                                "description": "must be a string and is required"
                            }
                        }
                    }
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


create_lecturer_profile_collection()
lecturer_profile_collection = db.lecturer_profile