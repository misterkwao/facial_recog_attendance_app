from pydantic import BaseModel
from datetime import datetime
from typing import Union


class TokenData(BaseModel):
    user_id: Union[str, None] = None
    user_name: str
    user_role: str


class ModelInput(BaseModel):
     age: int
     gender: int


class Token(BaseModel):
    access_token: str
    token_type: str


class AdminSignup(BaseModel):
    username: str
    email: str
    password: str

class AdminProfile(BaseModel):
    username: str
    owner: str

class AdminUpdate(BaseModel):
    username: str

class User(BaseModel):
    user_id: Union[str, None] = None
    user_name: str
    user_role: str

class allowedCourses(BaseModel):
        level: int
        semester: int
        course_title: str
        college: str
        department: str

class CreateLecturer(BaseModel):
    lecturer_name: str
    lecturer_email: str
    password: str
    allowed_courses: Union[list,allowedCourses]

class AdminUpdateLecturer(BaseModel):
     allowed_courses: Union[list,allowedCourses]

class semesterCourses(BaseModel):
     course_title: str
     no_of_attendance: int

class allowedStudentCourses(BaseModel):
     level: int
     first_semester_courses: Union[list,semesterCourses]
     second_semester_courses: Union[list,semesterCourses]


class CreateStudent(BaseModel):
     student_name: str
     student_email: str
     year_enrolled: int
     student_current_level: int
     student_current_semester: int
     password: str
     allowed_courses: Union[list,allowedStudentCourses]
     is_face_enrolled: bool
     student_college: str
     student_department: str

class StudentProfileUpdate(BaseModel):
     year_enrolled: int
     student_current_level: int
     student_name: str

class ClassLocation(BaseModel):
     longitude: float
     latitude: float

class CreateClass(BaseModel):
     course_title: str
     course_level: int
     course_semester_level: int
     location: ClassLocation
     start_time: datetime
     end_time: datetime
     no_of_attendees: int

class CreateClassLocation(BaseModel):
     class_name: str
     college_location: str
     location: ClassLocation