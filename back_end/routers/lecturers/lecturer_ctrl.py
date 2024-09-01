import math
import random
from fastapi import APIRouter, Depends, Response, UploadFile, status, HTTPException
from routers.lecturers import EncodeGen, recognition
import schemas
from typing import Annotated
import pydantic
from bson.objectid import ObjectId
from security import oauth2_lecturer
from datetime import datetime
from database.class_collection_db import class_collection
from database.lecturer_auth_profile_db import lecturer_profile_collection
from database.student_auth_profile_db import student_profile_collection
from database.class_collection_db import class_locations_collection
import time

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Lecturer Controls"]
)


@router.get('/lecturer')
async def get_profile(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            lecturer = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            return lecturer
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.post('/lecturer/enroll-face')
async def lecturer_enroll_face(file: UploadFile, current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            profile = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})

            image_bytes= await file.read()
            if EncodeGen.face_encode(image_bytes,current_user.user_name,profile["lecturer_department"]):
                lecturer_profile_collection.find_one_and_update({"owner": ObjectId(current_user.user_id)},{ '$set': { "is_face_enrolled" : True, "updatedAt": datetime.now()} })
                return {
                    "detail": "Face enrolled successfully",
                }
            
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.post("/lecturer/attendance/class", status_code=200)
async def mark_attendance(id,file: UploadFile,response: Response,current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":                 
        try:
            profile = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            curr_class = class_collection.find_one({"_id": ObjectId(id)})
            attendance_value = curr_class["no_of_attendees"]
            # Face recognition
            image_bytes= await file.read()
            lecturer = recognition.lecturer_face_recognition(image_bytes,profile["lecturer_department"])
            #  Updating class and lecturer attendance
            if profile["lecturer_name"] == lecturer:
               class_collection.find_one_and_update({"_id": ObjectId(id)},{ '$set': { "no_of_attendees" : (attendance_value+1), "updatedAt": datetime.now()}, 
                                                                           '$push':{"attendee_names": current_user.user_name}})
               return {"detail": "Attendance marked successfully"}
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return {
                    "detail": "Recognition failed"
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
   

@router.get('/lecturer/classes/current-classes')
async def get_current_classes(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            classes= list(class_collection.aggregate([
                { "$match": { "$expr" : { "$eq": [ '$creator' , { "$toObjectId": current_user.user_id } ] } } },
                { 
                                "$group": {
                                    "_id": {"year":{"$year": "$createdAt"},"month":{"$month":"$createdAt"},"week":{"$week": "$createdAt"}},
                                    "classes":{"$push":{"$cond": [ { "$eq": [{"$week": datetime.now()}, {"$week": "$createdAt"}] }, "$$CURRENT", "No classes"]}}
                                    }
                },
                {"$sort":{"_id":-1}},
                {"$limit": 1}
            ]))
            if classes:
                return{
                    "current_classes" : classes[0]["classes"]
                }
            else:
                return{
                    "current_classes" : ["no classes"]
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.get('/lecturer/classes/statistics')
async def get_class_statistics(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            #Getting the number of students per lecturer course
            # start_time = time.time()
            same_course_count = 0
            totals = {}
            lecturer = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            student_profiles = list(student_profile_collection.find({}))
            for lecturer_course in lecturer["allowed_courses"]:
                for student in student_profiles:
                    if student["student_current_level"] == lecturer_course["level"] and student["student_department"] == lecturer_course["department"]:
                        match lecturer_course["semester"]:
                            case 1:
                                for student_course in student["allowed_courses"][int((lecturer_course["level"]/100)-1)]["first_semester_courses"]:
                                    if student_course["course_title"] == lecturer_course["course_title"]:
                                        same_course_count += 1
                                        
                            case _:
                                for student_course in student["allowed_courses"][int((lecturer_course["level"]/100)-1)]["second_semester_courses"]:
                                    if student_course["course_title"] == lecturer_course["course_title"]:
                                        same_course_count += 1
                    
                    totals[lecturer_course["course_title"]]=same_course_count

                #Calculating performance for class attendance
            statistics = list(class_collection.aggregate([
                    { "$match": { "$expr" : { "$eq": [ '$creator' , { "$toObjectId": current_user.user_id } ] } } },
                    { 
                                "$group": {
                                    "_id":{"year":{"$year": "$createdAt"},"month":{"$month":"$createdAt"},"week":{"$week":"$createdAt"}},
                                    "data":{"$push":"$$CURRENT"}
                                    }
                    },
                    {
                        "$group": {
                            "_id": {"year":"$_id.year","month":"$_id.month"},
                            "weeks":{
                                "$push":{
                                    "week":"$_id.week",
                                    "classes":"$data"
                                }
                            } 
                        }
                    },
                    {"$unwind":"$weeks"},
                    {"$sort": {"weeks.week":1}},
                    {
                        "$group": {
                            "_id": {"year":"$_id.year","month":"$_id.month"},
                            "weeks":{
                                "$push":{
                                    "week":{"$add":["$weeks.week", 1]},
                                    "classes":"$weeks.classes" 
                                }
                            } 
                        }
                    },
                    {
                        "$group": {
                            "_id": {"year":"$_id.year","month":"$_id.month"},
                            "months":{
                                "$push":{
                                    "month":"$_id.month",
                                    "weeks":"$weeks"
                                }
                            } 
                        }
                    },
                    {"$unwind":"$months"},
                    {"$sort": {"months.month":-1}},
                    {
                        "$group": {
                            "_id": {"year":"$_id.year"},
                            "months":{
                                "$push":{
                                    "month":"$_id.month",
                                    "weeks":"$months.weeks"
                                }
                            } 
                        }
                    },
                    {"$sort": {"_id":-1}},
                    {"$limit": 1}
                ]))
                
            year = statistics[0]
            for month in year["months"]:
                for week in month["weeks"]:
                    for week_class in week["classes"]:
                            week_class["performance"] = ((week_class["no_of_attendees"]/totals[week_class["course_title"]])*100)
                            week_class["expected_no_attendees"] = totals[week_class["course_title"]]
            
            # print(f"It took {(time.time() - start_time)}")
            return statistics
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.get('/lecturer/classes/class-locations')
async def get_all_class_locations(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            class_locations = class_locations_collection.find({})
            if class_locations:
                return{
                    "class_locations": list(class_locations)
                }
        except Exception as e:
          raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.post('/lecturer/classes/class')
async def create_class(request:schemas.CreateClass,current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            create_class = class_collection.insert({
                "lecturer_name": current_user.user_name,
                "creator": ObjectId(current_user.user_id),
                "course_title": request.course_title,
                "course_level": request.course_level,
                "class_name": request.class_name,
                "course_semester_level": request.course_semester_level,
                "location":{
                    "longitude": request.location.longitude,
                    "latitude": request.location.latitude
                },
                "start_time": request.start_time,
                "end_time": request.end_time,
                "no_of_attendees": 0,
                "attendee_names": [],
                "test_link": request.test_link,
                "test_attendee_names":[],
                "createdAt": datetime.now()
            })
            if create_class:
                return {
                    "detail": "Class created Successfully"
                }
        except Exception as e:
            response = str(e)
            if "Document failed validation" in response:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Please provide required fields")
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    

@router.delete("/lecturer/classes/class")
async def delete_class(id, current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            delete_class = class_collection.find_one_and_delete({"_id": ObjectId(id)})
            if delete_class:
                return{
                    "detail": "Class deleted Successfully"
                }
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Class not found")
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    
@router.patch("/lecturer/classes/class")
async def update_class(id, request: schemas.UpdateClass,response: Response,current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            update_class = class_collection.find_one_and_update({"_id": ObjectId(id)},{ '$set': 
                                                                                       { 
                                                                                        "class_name": request.class_name,
                                                                                        "location":{
                                                                                            "longitude": request.location.longitude,
                                                                                            "latitude": request.location.latitude
                                                                                        },
                                                                                        "start_time": request.start_time,
                                                                                        "end_time": request.end_time,
                                                                                        "test_link": request.test_link,
                                                                                        "updatedAt": datetime.now()
                                                                                        } })
            if update_class:
                #sending notification
                if request.test_link == "":
                    match update_class["course_semester_level"]:
                        case 1:
                            student_profile_collection.update_many(
                                                            {"$and":[
                                                                {"student_current_level": {"$eq": update_class["course_level"]}},
                                                                {"student_current_semester":{"$eq": update_class["course_semester_level"]}},
                                                                {f'allowed_courses.{((update_class["course_level"])//100)-1}.first_semester_courses':{ "$elemMatch": { "course_title": update_class["course_title"]} }}
                                                                ]},
                                                            {"$push": {
                                                                "notifications":{
                                                                    "_id": ObjectId(),
                                                                    "title":f'{update_class["course_title"]} has been updated!',
                                                                    "details":{
                                                                        "class_id":ObjectId(update_class['_id']),
                                                                        "description":"Please check your upcoming classes to view changes",
                                                                        "is_read": False
                                                                    },
                                                                    "createdAt":datetime.now()
                                                                }
                                                                }
                                                            }
                                                        )
                            return{
                                   "detail": "Class updated Successfully"
                                   }
                        case _:
                            student_profile_collection.update_many(
                                                    {"$and":[
                                                        {"student_current_level": {"$eq": update_class["course_level"]}},
                                                        {"student_current_semester":{"$eq": update_class["course_semester_level"]}},
                                                        {f'allowed_courses.{((update_class["course_level"])//100)-1}.second_semester_courses':{ "$elemMatch": { "course_title": update_class["course_title"]} }}
                                                        ]},
                                                    {"$push": {
                                                        "notifications":{
                                                                    "_id": ObjectId(),
                                                                    "title":f'{update_class["course_title"]} has been updated!',
                                                                    "details":{
                                                                        "class_id":ObjectId(update_class['_id']),
                                                                        "description":"Please check your upcoming classes to view changes",
                                                                        "is_read": False
                                                                    },
                                                                    "createdAt":datetime.now()
                                                                }
                                                        }
                                                    },
                                                )
                            return{
                                "detail": "Class updated Successfully"
                            }
                else:
                    match update_class["course_semester_level"]:
                        case 1:
                            student_profile_collection.update_many(
                                                            {"$and":[
                                                                {"student_current_level": {"$eq": update_class["course_level"]}},
                                                                {"student_current_semester":{"$eq": update_class["course_semester_level"]}},
                                                                {f'allowed_courses.{((update_class["course_level"])//100)-1}.first_semester_courses':{ "$elemMatch": { "course_title": update_class["course_title"]} }}
                                                                ]},
                                                            {"$push": {
                                                                "notifications":{
                                                                    "_id": ObjectId(),
                                                                    "title":f'Class assessment for {update_class["course_title"]}!',
                                                                    "details":{
                                                                        "class_id":ObjectId(update_class['_id']),
                                                                        "description":"Please tap on this notification to partake the assessment.Note that once you leave the app during the assessment you wont be able to re-take it",
                                                                        "link":request.test_link,
                                                                        "is_read": False
                                                                    },
                                                                    "createdAt":datetime.now()
                                                                }
                                                                }
                                                            },
                                                        )
                            return{
                                   "detail": "Class updated Successfully"
                                   }
                        case _:
                            student_profile_collection.update_many(
                                                    {"$and":[
                                                        {"student_current_level": {"$eq": update_class["course_level"]}},
                                                        {"student_current_semester":{"$eq": update_class["course_semester_level"]}},
                                                        {f'allowed_courses.{((update_class["course_level"])//100)-1}.second_semester_courses':{ "$elemMatch": { "course_title": update_class["course_title"]} }}
                                                        ]},
                                                    {"$push": {
                                                        "notifications":{
                                                                    "_id": ObjectId(),
                                                                    "title":f'Class assessment for {update_class["course_title"]}!',
                                                                    "details":{
                                                                        "class_id":ObjectId(update_class['_id']),
                                                                        "description":"Please tap on this notification to partake the assessment\n Note that once you leave the app you wont be able to re-take the assessment",
                                                                        "link":request.test_link,
                                                                        "is_read": False
                                                                    },
                                                                    "createdAt":datetime.now()
                                                                }
                                                        }
                                                    },
                                                )
                            return{
                                "detail": "Class updated Successfully"
                            }
                
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return {
                    "detail": "Class not found"
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    
@router.patch("/lecturer/update-notifications", status_code=200)
async def notification_update(id,response: Response,request:schemas.UpdateNotification,current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    if current_user.user_role == "lecturer":
        try:
            result = lecturer_profile_collection.update_one({"owner": ObjectId(current_user.user_id),"notifications._id":ObjectId(id)},
                                                                     {"$set":{"notifications.$[elem].details.is_read": True}},
                                                                     array_filters = [{
                                                                            "elem._id": ObjectId(id)
                                                                        }]
                                                                     )
            # Check if the update was successful
            if result.modified_count > 0:
                return "Update successful"
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return "Update failed"
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")