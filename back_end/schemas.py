from pydantic import BaseModel
from typing import Union


class TokenData(BaseModel):
    user_id: Union[str, None] = None


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
    id: str

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
     password: str
     allowed_courses: Union[list,allowedStudentCourses]
     is_face_enrolled: bool
     student_college: str
     student_department: str

class StudentProfileUpdate(BaseModel):
     year_enrolled: int
     student_current_level: int
     student_name: str