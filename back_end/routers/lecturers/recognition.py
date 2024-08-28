import face_recognition
import numpy as np
import joblib
from io import BytesIO
from PIL import Image, ExifTags

def lecturer_face_recognition(lecturer_image,lecturer_department):
    # Importing the encoding file
    # print("Loading encoding file...")
    file =open(f"Encodings/Lecturers/{lecturer_department}.joblib", 'rb')
    facialencodingsWithNames = joblib.load(file)
    encodings, lecturer_names = facialencodingsWithNames
    file.close()

    # Function to correct image orientation based on EXIF data
    def correct_image_orientation(image):
        try:
            for orientation in ExifTags.TAGS.keys():
                if ExifTags.TAGS[orientation] == 'Orientation':
                    break
            exif = image._getexif()
            if exif is not None:
                orientation = exif.get(orientation, None)
                if orientation == 3:
                    image = image.rotate(180, expand=True)
                elif orientation == 6:
                    image = image.rotate(270, expand=True)
                elif orientation == 8:
                    image = image.rotate(90, expand=True)
        except (AttributeError, KeyError, IndexError):
            # Cases: image don't have getexif
            pass
        return image

    # Function to resize image if it is too large
    def resize_image(image, max_width=800, max_height=800):
        width, height = image.size
        if width > max_width or height > max_height:
            new_width = min(width, max_width)
            new_height = int((new_width / width) * height)
            if new_height > max_height:
                new_height = max_height
                new_width = int((new_height / height) * width)
            image = image.resize((new_width, new_height))
        return image

    # Load and possibly resize the image
    def load_and_prepare_image(image_bytes):
        image = Image.open(BytesIO(image_bytes))
        image = correct_image_orientation(image)
        image = resize_image(image)
        
        # Check and set a default format if not available
        image_format = image.format if image.format else 'JPEG'
        
        # Save the corrected and resized image to bytes
        image_bytes_io = BytesIO()
        image.save(image_bytes_io, format=image_format)
        image_bytes_io.seek(0)
        
        return face_recognition.load_image_file(image_bytes_io)


   
    # recognition against database
    image = load_and_prepare_image(lecturer_image)

    faceCurFrame = face_recognition.face_locations(image)
    face_landmarks_list = face_recognition.face_landmarks(image)
    encodeCurFrame = face_recognition.face_encodings(image,faceCurFrame)

    for encodedFace, faceLocation in zip(encodeCurFrame, faceCurFrame):
        matches = face_recognition.compare_faces(encodings, encodedFace)
        faceDis = face_recognition.face_distance(encodings, encodedFace)
        # face distance ensure more accuracy
        # print("matches: ", matches)
        # print("faceDis: ", faceDis)
        matchIndex = np.argmin(faceDis)
        if matches[matchIndex]:
            return lecturer_names[matchIndex]
        else:
            return "Not registered"