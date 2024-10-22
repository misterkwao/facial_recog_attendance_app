from fastapi import APIRouter, Depends, status, HTTPException, UploadFile, Response
import schemas
from typing import Annotated
import math
from PIL import Image
from io import BytesIO
import piexif
from . import EncodeGen, recognition
import pydantic
from bson.objectid import ObjectId
from security import oauth2_student
from datetime import datetime
from database.class_collection_db import class_collection
from database.student_auth_profile_db import student_profile_collection
pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Student Controls"]
)

@router.get('/student',status_code=200)
async def student_profile(response: Response,current_user:schemas.User = Depends(oauth2_student.get_current_user)):
    if current_user.user_role == "student":     
        student_classes = []
        # querying against the actual courses
        def class_match(student_current_level):
            number = math.ceil((student_current_level/100)-1) # To get the array number of the student's current level
            for upcoming_class in classes[0]["classes"]:
                match upcoming_class["course_semester_level"]:
                    case 1:
                        # searching first semester courses
                        for index,course in enumerate(profile["allowed_courses"][number]["first_semester_courses"]):
                            if course["course_title"] == upcoming_class["course_title"]:
                                student_classes.append(upcoming_class)
                    case _:
                        # searching second semester courses
                        for index,course in enumerate(profile["allowed_courses"][number]["second_semester_courses"]):
                            if course["course_title"] == upcoming_class["course_title"]:
                                                student_classes.append(upcoming_class)


        try:
            profile = student_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            if profile is not None:
                student_current_level = profile["student_current_level"]
                classes =  list(class_collection.aggregate([
                    {
                    "$match": { "course_level": student_current_level}
                    },
                    { 
                                "$group": {
                                    "_id": {"year":{"$year": "$createdAt"},"month":{"$month":"$createdAt"},"week":{"$week": "$createdAt"}},
                                    "classes":{"$push":{"$cond": [ { "$eq": [{"$week": datetime.now()}, {"$week": "$createdAt"}] }, "$$CURRENT", "No classes"]}}
                                    }
                    },
                    {"$sort":{"_id": -1}},
                    {"$limit" :1}
                ]))
                if classes and ("No classes" not in classes[0]["classes"]):
                    #This means there are classes
                    class_match(student_current_level)

                    return {
                        "profile": profile,
                        "upcoming_classes":student_classes
                    }
                else:
                     return {
                        "profile": profile,
                        "upcoming_classes": "No Upcoming Classes"
                    }
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return "Student does not exist"
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.post('/student/enroll-face')
async def student_enroll_face(file: UploadFile, current_user:schemas.User = Depends(oauth2_student.get_current_user)):
    if current_user.user_role == "student":
        try:
            profile = student_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})

            image_bytes= await file.read()
            if EncodeGen.face_encode(image_bytes,current_user.user_name,profile["student_department"],profile["year_enrolled"]):
                student_profile_collection.find_one_and_update({"owner": ObjectId(current_user.user_id)},{ '$set': { "is_face_enrolled" : True, "updatedAt": datetime.now()} })
                return {
                    "detail": "Face enrolled successfully",
                }
            
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.post("/student/attendance/class", status_code=200)
async def mark_attendance(id,file: UploadFile,response: Response,current_user:schemas.User = Depends(oauth2_student.get_current_user)):
    if current_user.user_role == "student":
     # getting the no of attendance value from student
        def class_match(course_level):
            number = math.ceil((course_level/100)-1) # To get the array number of the student's current level
            match curr_class["course_semester_level"]:
                case 1:
                    # searching first semester courses
                    for index,course in enumerate(profile["allowed_courses"][number]["first_semester_courses"]):
                        if course["course_title"] == curr_class["course_title"]:
                            return course["no_of_attendance"], index
                case _:
                    # searching second semester courses
                    for index,course in enumerate(profile["allowed_courses"][number]["second_semester_courses"]):
                        if course["course_title"] == curr_class["course_title"]:
                            return course["no_of_attendance"], index
                                
        try:
            profile = student_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            curr_class = class_collection.find_one({"_id": ObjectId(id)})
            attendance_value = curr_class["no_of_attendees"]

            no_of_att, course_index = class_match(curr_class["course_level"])

            # Face recognition
            image_bytes= await file.read()
            student = recognition.student_face_recognition(image_bytes,profile["student_department"],profile["year_enrolled"])
            #  Updating class and student attendance
            if profile["student_name"] == student:
               class_collection.find_one_and_update({"_id": ObjectId(id)},{ '$set': { "no_of_attendees" : (attendance_value+1), "updatedAt": datetime.now()}, 
                                                                           '$push':{"attendee_names": current_user.user_name}})
               match curr_class["course_semester_level"]:
                        case 1:
                            number = math.ceil((curr_class["course_level"]/100)-1)
                            student_profile_collection.find_one_and_update(
                                                            {"owner": ObjectId(current_user.user_id)},
                                                            { '$set': { f"allowed_courses.{number}.first_semester_courses.{course_index}.no_of_attendance" : (no_of_att+1), "updatedAt": datetime.now()} }
                                                                )
                            return {
                                "detail": "Attendance marked successfully"
                            }
                        case _:
                            number = math.ceil((curr_class["course_level"]/100)-1)
                            student_profile_collection.find_one_and_update(
                                                            {"owner": ObjectId(current_user.user_id)},
                                                            { '$set': { f"allowed_courses.{number}.second_semester_courses.{course_index}.no_of_attendance" : (no_of_att+1), "updatedAt": datetime.now()} }
                                                                )
                            return {
                                "detail": "Attendance marked successfully"
                            }
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return {
                    "detail": "Recognition failed"
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.post("/student/attendance/assessment", status_code=200)
async def mark_assessment_attendance(id,file: UploadFile,response: Response,current_user:schemas.User = Depends(oauth2_student.get_current_user)):
    if current_user.user_role == "student":                         
        try:
            profile = student_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
            # Face recognition
            image_bytes= await file.read()
            student = recognition.student_face_recognition(image_bytes,profile["student_department"],profile["year_enrolled"])
            #  Updating class and student attendance
            if profile["student_name"] == student:
               class_collection.find_one_and_update({"_id": ObjectId(id)},{'$push':{"test_attendee_names": current_user.user_name}})
               return {
                        "detail": "Attendance marked successfully"
                      }
            else:
                response.status_code = status.HTTP_400_BAD_REQUEST
                return {
                    "detail": "Recognition failed"
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    
@router.patch("/student/update-notification", status_code=200)
async def notification_update(id,response: Response,current_user:schemas.User = Depends(oauth2_student.get_current_user)):
    if current_user.user_role == "student":
        try:
            result = student_profile_collection.update_one({"owner": ObjectId(current_user.user_id),"notifications._id":ObjectId(id)},
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