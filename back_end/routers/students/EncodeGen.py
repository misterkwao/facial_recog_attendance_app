import face_recognition
import joblib
from PIL import Image, ExifTags
from io import BytesIO

def face_encode(image,student_name,student_college,student_year_enrolled):

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


    # Load the image and possibly resize it
    new_student_name = student_name
    new_student_image = load_and_prepare_image(image)

    def image_to_encoding(student_images):
        face_locations = face_recognition.face_locations(student_images)
        if len(face_locations) == 0:
            return "No face found in the image."
        else:
            encodings = face_recognition.face_encodings(student_images)[0]
        return encodings

    new_encoding = image_to_encoding(new_student_image)
    #print(new_encoding)
    
    

    # loading existing joblib file to append new encoding
    try:
        file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'rb')
        facialencodingsWithNames = joblib.load(file)
        encodings, student_names = facialencodingsWithNames
        file.close()

        # appending new encoding
        encodings.append(new_encoding) #Appending new encoding for new student

        # appending new student name
        student_names.append(new_student_name) #Appending new name for new student

        # saving new details
        facialencodingsWithNames = [encodings, student_names]
        # print(facialencodingsWithNames)
        file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'wb')
        joblib.dump(facialencodingsWithNames, file)
        file.close()
        return True #This means the file was Updated successfully
    except:
        facialencodingsWithNames = [[new_encoding], [new_student_name]]
        # print(facialencodingsWithNames)
        file = open(f"Encodings/{student_college}_{student_year_enrolled}.joblib", 'wb')
        joblib.dump(facialencodingsWithNames, file)
        file.close()
        return True #This means the file was successfully saved