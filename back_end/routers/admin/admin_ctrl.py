from fastapi import APIRouter, Depends, status, HTTPException
from security import oauth2_Admin
import schemas
import pydantic
from bson.objectid import ObjectId
from database.admin_auth_profile_db import admin_auth_collection, admin_profile_collection
from database.lecturer_auth_profile_db import lecturer_auth_collection,lecturer_profile_collection
from database.student_auth_profile_db import student_auth_collection, student_profile_collection
from database.class_collection_db import class_locations_collection
from security import hashing
from datetime import datetime

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str

router = APIRouter(
    prefix="/api/v1",
    tags=["Admin Controls"]
)


# Admin functionalities
@router.get('/admin')
async def get_admin_profile(current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
      try:
        return admin_profile_collection.find_one({"owner": ObjectId(current_user.user_id)})
      except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.patch('/admin')
async def update_admin_profile(request:schemas.AdminUpdate,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
       if current_user.user_role == "admin":
            admin_profile = admin_profile_collection.find_one_and_update({"owner": ObjectId(current_user.user_id)},{ '$set': { "username" : request.username,"updatedAt":datetime.now()} })
            admin_auth =  admin_auth_collection.find_one_and_update({"_id": ObjectId(current_user.user_id)},{ '$set': { "username" : request.username,"updatedAt":datetime.now()} })
            if admin_auth and admin_profile:
                return {
                        "detail": "Successfully updated"
                    }
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
       else:
           raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.delete('/admin')
async def delete_admin_account(current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
       if current_user.user_role == "admin":
            admin_profile = admin_profile_collection.find_one_and_delete({"owner": ObjectId(current_user.user_id)})
            admin_auth = admin_auth_collection.find_one_and_delete({"_id": ObjectId(current_user.user_id)})
            if admin_auth and admin_profile:
                return {
                            "detail": "Account successfully deleted"
                        }
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
       else:
           raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

       
# Student and Lecturer functionalities
@router.get('/admin/user-manangement/all')
async def get_all_users(current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
   if current_user.user_role == "admin":
        try:
            lecturer_profiles = lecturer_profile_collection.find({})
            student_profiles = student_profile_collection.find({})
            if lecturer_profiles and student_profiles:
                return{
                    "lecturers":list(lecturer_profiles),
                    "students": list(student_profiles)
                } 
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
   else:
       raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


#Class methods
@router.post('/admin/user-manangement/class')
async def create_class_location(request:schemas.CreateClassLocation,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        try:
            create_class_location = class_locations_collection.insert({
                "class_name": request.class_name,
                "college_location": request.college_location,
                "location":{
                    "longitude": request.location.longitude,
                    "latitude": request.location.latitude
                },
                "createdAt": datetime.now()
            })
            if create_class_location:
                return {
                    "detail": "Class location created Successfully"
                }
        except Exception as e:
            response = str(e)
            if "duplicate key error collection" in response:
             raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Class location already exists")
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.get('/admin/user-manangement/class')
async def get_all_class_locations(current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
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

@router.delete("/admin/user-manangement/class")
async def delete_class_location(id: str, current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        class_location = class_locations_collection.find_one_and_delete({"_id": ObjectId(id)})
        if class_location:
            return {
            "detail": "Successfully deleted"
        }
        else:
         raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")



# Admin to lecturer functionalities
@router.post('/admin/user-manangement/lecturer')
async def create_lecturer(request:schemas.CreateLecturer,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        # Hash incoming request password
        hashed_password = hashing.Hash.get_pwd_hashed(request.password)
        try:
            lecturer = lecturer_auth_collection.insert({
                "lecturer_name": request.lecturer_name,
                "lecturer_email": request.lecturer_email,
                "password": hashed_password,
                "createdAt": datetime.now()
                })
            lecturer_profile_collection.insert({
                "owner": lecturer,
                "lecturer_name": request.lecturer_name,
                "allowed_courses":request.allowed_courses,
                "createdAt": datetime.now()
            })
            return{
                "detail":"User created successfully"
            }
        except Exception as e:
            response = str(e)
            if "document failed validation" in response:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Please provide required fields and make sure allowed courses are  not repeated.")
            elif "duplicate key error collection" in response:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email is already registered")
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")

@router.patch("/admin/user-manangement/lecturer")
async def update_lecturer(request:schemas.AdminUpdateLecturer,id: str,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        # This function only updates the allowed courses of a lecturer
        # In order for simple update, 
        # if you want to added new courses, just add the new course to the already existing courses and send the json array of objects
        # if you want to delete a course, remove the course from the existing courses and send the json array of objects
        try:
            lecturer_profile = lecturer_profile_collection.find_one_and_update({"owner": ObjectId(id)},{ '$set': { "allowed_courses" : request.allowed_courses, "updatedAt": datetime.now()} })
            if lecturer_profile:
                return{
                    "detail":"Successfully updated"
                }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    

@router.delete("/admin/user-manangement/lecturer")
async def delete_lecturer(id: str,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        lecturer = lecturer_auth_collection.find_one_and_delete({"_id": ObjectId(id)})
        lecturer_profile = lecturer_profile_collection.find_one_and_delete({"owner": ObjectId(id)})

        if lecturer and lecturer_profile:
            return {
                "detail": "Successfully deleted"
            }
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    

# Admin to student  functionalities
@router.post('/admin/user-manangement/student')
async def create_student(request:schemas.CreateStudent,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        # Hash incoming request password
        hashed_password = hashing.Hash.get_pwd_hashed(request.password)
        try:
            student_auth = student_auth_collection.insert({
                "student_name": request.student_name,
                "student_email": request.student_email,
                "password": hashed_password,
                "createdAt": datetime.now()
                })
            student_profile = student_profile_collection.insert({
                "owner": student_auth, #student variable stores student id
                "student_name": request.student_name,
                "year_enrolled" :request.year_enrolled,
                "student_current_level": request.student_current_level,
                "student_current_semester": request.student_current_semester,
                "is_face_enrolled": request.is_face_enrolled,
                "student_college": request.student_college,
                "student_department": request.student_department,
                "allowed_courses": request.allowed_courses,
                "createdAt": datetime.now()
            })
            if student_auth and student_profile:
                return {
                    "detail": "Student successfully created"
                }
        except Exception as e:
            response = str(e)
            if "document failed validation" in response:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Please provide required fields and make sure allowed courses are  not repeated.")
            elif "duplicate key error collection" in response:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email is already registered")
            else:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f'{e}')
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
        

@router.patch("/admin/user-manangement/student")
async def update_student(request:schemas.StudentProfileUpdate,id: str,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        # These are the selected fields that can be changed without affecting data integrity
        try:
            student_name_update = student_auth_collection.find_one_and_update({"_id": ObjectId(id)},{ '$set': { "student_name": request.student_name} })
            student_update = student_profile_collection.find_one_and_update({"owner": ObjectId(id)},
                                                        { '$set': { "year_enrolled" : request.year_enrolled,
                                                                    "student_current_level": request.student_current_level,
                                                                    "student_current_semester": request.student_current_semester,
                                                                    "student_name": request.student_name,
                                                                    "updatedAt": datetime.now()
                                                                    } }
                                                                    )
            if student_update and student_name_update:
                return{
                        "detail":"Successfully updated"
                    }
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"{e}")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")


@router.delete("/admin/user-manangement/student")
async def delete_student(id: str,current_user:schemas.User = Depends(oauth2_Admin.get_current_user)):
    if current_user.user_role == "admin":
        student_auth = student_auth_collection.find_one_and_delete({"_id": ObjectId(id)})
        student_profile =student_profile_collection.find_one_and_delete({"owner": ObjectId(id)})

        if student_auth and student_profile:
            return {
                "detail": "Successfully deleted"
            }
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Something went wrong")
    else:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access denied")
    