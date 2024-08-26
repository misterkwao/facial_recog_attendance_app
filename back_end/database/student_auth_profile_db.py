# This file contains the student auth collection and paired profile collection
# This done to add a layer of data hiding
from pymongo import MongoClient
import pymongo
from dotenv import  dotenv_values

config = dotenv_values('.env')

client = MongoClient(config['MONGO_URI'])
db = client.facerecog_db #name of database

def create_student_auth_collection():
    try:
        db.create_collection("student_auth")
    except Exception as e:
        return e
    
    db.command("collMod", "student_auth", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["student_name", "student_email", "password"],
            "properties": {
                "student_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "student_email": {
                    "bsonType": "string",
                    "pattern": "^\\S+@\\S+\\.\\S+$",
                    "description": "must be a string and is required"
                },
                "password": {
                    "bsonType": "string",
                    "minLength":8,
                    "description": "must be a string and is required"
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

create_student_auth_collection()
student_auth_collection = db.student_auth
student_auth_collection.create_index([("student_email", pymongo.ASCENDING)], unique=True)


def create_student_profile_collection():
    try:
        db.create_collection("student_profile")
    except Exception as e:
        return e
    
    db.command("collMod", "student_profile", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["student_name", "owner", "year_enrolled", "student_current_level","student_current_semester","allowed_courses","is_face_enrolled","student_college","student_department"],
            "properties": {
                "student_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "year_enrolled": {
                    "bsonType": "int",
                    "description": "must be an integer and is required"
                },
                "student_current_level":{
                    "bsonType": "int",
                    "description": "must be an integer and is required"
                },
                "student_current_semester":{
                    "bsonType": "int",
                    "description": "must be an integer and is required"
                },
                "owner": {
                    "bsonType": "objectId",
                    "description": "must be a string and is required"
                },
                "is_face_enrolled":{
                    "bsonType": "bool",
                    "description": "must be a boolean and is required"  
                },
                "student_college":{
                    "bsonType": "string",
                    "description": "must be a string and is required"  
                },
                "student_department":{
                    "bsonType": "string",
                    "description": "must be a string and is required"  
                },
                "allowed_courses":{
                    "bsonType": "array",
                    "minItems": 1,
                    "uniqueItems": True,
                    "additionalProperties": False,
                    "items":{
                        "bsonType": "object",
                        "required": ["level","first_semester_courses","second_semester_courses"],
                        "additionalProperties": False,
                        "description": "'items' must contain the stated fields.",
                        "properties":{
                            "level":{
                                "bsonType": "int",
                                "description":"must be the level of student to be lectured"
                            },
                            "first_semester_courses":{
                                "bsonType": "array",
                                "minItems": 1,
                                "uniqueItems": True,
                                "additionalProperties": False,
                                "items":{
                                    "bsonType": "object",
                                    "required": ["course_title","no_of_attendance"],
                                    "additionalProperties": False,
                                    "description": "'items' must contain the stated fields.",
                                    "properties":{
                                        "course_title":{
                                            "bsonType": "string",
                                            "description": "must be a string and is required"
                                        },
                                        "no_of_attendance":{
                                            "bsonType": "int",
                                            "description": "must be an integer and is required"
                                        }
                                    }
                                }
                            },
                             "second_semester_courses":{
                                "bsonType": "array",
                                "minItems": 1,
                                "uniqueItems": True,
                                "additionalProperties": False,
                                "items":{
                                    "bsonType": "object",
                                    "required": ["course_title","no_of_attendance"],
                                    "additionalProperties": False,
                                    "description": "'items' must contain the stated fields.",
                                    "properties":{
                                        "course_title":{
                                            "bsonType": "string",
                                            "description": "must be a string and is required"
                                        },
                                        "no_of_attendance":{
                                            "bsonType": "int",
                                            "description": "must be an integer and is required"
                                        }
                                    }
                                }
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


create_student_profile_collection()
student_profile_collection = db.student_profile