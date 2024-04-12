from fastapi import APIRouter, Depends, status, HTTPException
import schemas
from typing import Annotated
import pydantic
from bson.objectid import ObjectId
from security import oauth2_lecturer
from datetime import datetime
from database.class_collection_db import class_collection
from database.lecturer_auth_profile_db import lecturer_profile_collection

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Lecturer Controls"]
)


@router.get('/lecturer')
async def get_admin_profile(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
    try:
       lecturer = lecturer_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
       return lecturer
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    

@router.get('/lecturer/classes')
async def get_class_statistics(current_user:schemas.User = Depends(oauth2_lecturer.get_current_user)):
#    More aggregation would be added later
    try:
        statistics = class_collection.aggregate([
            { "$match": { "$expr" : { "$eq": [ '$creator' , { "$toObjectId": current_user.user_id } ] } } },
            { 
                        "$group": {
                            "_id": {"year":{"$year": "$createdAt"}},
                            "classes":{"$push": "$$CURRENT"}
                            }
            }
        ])
        return {"data": list(statistics)}
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
    