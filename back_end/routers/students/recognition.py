import face_recognition
import numpy as np
import joblib
from io import BytesIO

def student_face_recognition(stu_image,student_college,student_year_enrolled):
    # Importing the encoding file
    # print("Loading encoding file...")
    file =open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'rb')
    facialencodingsWithNames = joblib.load(file)
    encoding, student_names = facialencodingsWithNames
    file.close()

    # recognition against database
    image = face_recognition.load_image_file(BytesIO(stu_image))

    faceCurFrame = face_recognition.face_locations(image)
    face_landmarks_list = face_recognition.face_landmarks(image)
    encodeCurFrame = face_recognition.face_encodings(image, faceCurFrame)

    for encodedFace, faceLocation in zip(encodeCurFrame, faceCurFrame):
        matches = face_recognition.compare_faces(encoding, encodedFace)
        faceDis = face_recognition.face_distance(encoding, encodedFace)
        # print("matches: ", matches)
        # print("faceDis: ", faceDis)
        matchIndex = np.argmin(faceDis)
        if matches[matchIndex]:
            return student_names[matchIndex]