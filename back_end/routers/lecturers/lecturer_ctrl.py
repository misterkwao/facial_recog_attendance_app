from fastapi import APIRouter, Depends, status, HTTPException
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

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Lecturer Controls"]
)


@router.get('/lecturer')
async def get_profile(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    try:
       lecturer = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
       return lecturer
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    
@router.get('/lecturer/classes/statistics')
async def get_class_statistics(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):

    try:
       #Getting the number of students per lecturer course
       same_course_count = 0
       totals = {"Mathematics":150}
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
            
               totals[student_course["course_title"]]=same_course_count

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
            {"$sort": {"_id":-1}},
            {"$limit": 1}
        ]))
        
       for month in statistics:
           for week in month["weeks"]:
               for wk_class in week["classes"]:
                   wk_class["performance"] = ((wk_class["no_of_attendees"]/totals[wk_class["course_title"]])*100)
                   wk_class["expected_no_attendees"] = totals[wk_class["course_title"]]
           
       return statistics
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")

@router.get('/lecturer/classes/class-locations')
async def get_all_class_locations(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    try:
        class_locations = class_locations_collection.find({})
        if class_locations:
            return{
                "class_locations": list(class_locations)
            }
    except Exception as e:
       raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")

@router.post('/lecturer/classes/class')
async def create_class(request:schemas.CreateClass,current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    try:
        create_class = class_collection.insert({
            "lecturer_name": current_user.user_name,
            "creator": ObjectId(current_user.user_id),
            "course_title": request.course_title,
            "course_level": request.course_level,
            "course_semester_level": request.course_semester_level,
            "location":{
                "longitude": request.location.longitude,
                "latitude": request.location.latitude
            },
            "start_time": request.start_time,
            "end_time": request.end_time,
            "no_of_attendees":request.no_of_attendees,
            "createdAt": datetime.now()
        })
        if create_class:
            return {
                "detail": "Class created Successfully"
            }
    except Exception as e:
        response = str(e)
        if "document failed validation" in response:
           raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Please provide required fields")
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
    

@router.delete("/lecturer/classes/class/{id}")
async def delete_class(id, current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
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
    