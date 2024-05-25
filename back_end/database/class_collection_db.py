# This file contains the classes database and schema
from pymongo import MongoClient
import pymongo
from dotenv import  dotenv_values

config = dotenv_values('.env')

client = MongoClient(config['MONGO_URI'])
db = client.facerecog_db #name of database

#Students and lecturer classes
def create_class_collection():
    try:
        db.create_collection("stu_lec_classes")
    except Exception as e:
        return e
    
    db.command("collMod", "stu_lec_classes", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["lecturer_name", "creator","course_title", "course_level","course_semester_level","start_time","end_time","no_of_attendees","location"],
            "properties": {
                "lecturer_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "creator": {
                    "bsonType": "objectId",
                    "description": "must be a string and is required"
                },
                "course_title": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "course_level":{
                    "bsonType": "int",
                    "description": "must be an integer and is required"
                },
                "course_semester_level":{
                    "bsonType": "int",
                    "description": "must be an integer and is required"
                },
                "location": {
                    "bsonType": "object",
                    "required": ["longitude", "latitude"],
                        "additionalProperties": False,
                        "description": "'items' must contain the stated fields.",
                        "properties":{
                            "longitude":{
                                "bsonType": "double",
                                "description":"must be the level of student to be lectured"
                            },
                            "latitude":{
                                "bsonType": "double",
                                "description": "must be a integer and is required"
                            }
                        }
                },
                "start_time":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                },
                "end_time":{
                    "bsonType": "date",
                    "description": "must be a date and is required"
                },
                "no_of_attendees":{
                    "bsonType": "int",
                    "description": "must be a int and is required"
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


create_class_collection()
class_collection =db.stu_lec_classes

#Class locations
def create_class_location_collection():
    try:
        db.create_collection("class_locations")
    except Exception as e:
        return e
    
    db.command("collMod", "class_locations", validator={
            "$jsonSchema": {
            "bsonType": "object",
            "required": ["class_name", "college_location","location"],
            "properties": {
                "class_name": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "college_location": {
                    "bsonType": "string",
                    "description": "must be a string and is required"
                },
                "location": {
                    "bsonType": "object",
                    "required": ["longitude", "latitude"],
                        "additionalProperties": False,
                        "description": "'items' must contain the stated fields.",
                        "properties":{
                            "longitude":{
                                "bsonType": "double",
                                "description":"must be the level of student to be lectured"
                            },
                            "latitude":{
                                "bsonType": "double",
                                "description": "must be a integer and is required"
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


create_class_location_collection()
class_locations_collection = db.class_locations

#To prevent duplicate class
class_locations_collection.create_index([("class_name", pymongo.ASCENDING)], unique=True)