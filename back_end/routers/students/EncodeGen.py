import face_recognition
import joblib
from io import BytesIO

def face_encode(image,filename,student_college,student_year_enrolled):
    # assuming new student enrolls the face
    new_student_name = []
    new_student_image = []

    new_student_name.append(filename.split('.')[0])
    new_student_image.append(face_recognition.load_image_file(BytesIO(image)))

    def image_to_enconding(student_images):
        encodings = face_recognition.face_encodings(student_images[0])[0]
        return encodings


    new_encoding = image_to_enconding(new_student_image)

    # loading existing joblib file to append new encoding

    # try:
    #     file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'rb')
    #     facialencodingsWithNames = joblib.load(file)
    #     encoding, student_names = facialencodingsWithNames
    #     file.close()

    #     # appending new encoding
    #     updated_encodings =[]
    #     updated_encodings.append(encoding) #Appending already existing encodings
    #     updated_encodings.append(new_encoding) #Appending new encoding for new student

    #     updated_names =[]
    #     updated_names.append(student_names) #Appending already existing names
    #     updated_names.append(new_student_name) #Appending new name for new student

    #     # saving new details
    #     facialencodingsWithNames = [updated_encodings, updated_names]
    #     file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'wb')
    #     joblib.dump(facialencodingsWithNames, file)
    #     file.close()
    #     return True #This means the file was Updated successfully
    # except:
    facialencodingsWithNames = [new_encoding, new_student_name]
    file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'wb')
    joblib.dump(facialencodingsWithNames, file)
    file.close()
    return True #This means the file was successfully saved