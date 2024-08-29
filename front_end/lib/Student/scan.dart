// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Pages/lecturer_page.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';
import 'package:student_attendance_app/Providers/students_page_provider.dart';

import '../Auth/api.dart';
import '../Pages/student_page.dart';
import '../main.dart';

class ScanFace extends StatefulWidget {
  final String classId;
  const ScanFace({required this.classId, super.key});

  @override
  State<ScanFace> createState() => _ScanFaceState();
}

class _ScanFaceState extends State<ScanFace> {
  late CameraController controller;
  late FaceDetector _faceDetector;
  bool _isUserLookingAtCamera = false;
  bool _isDetecting = false;
  bool _isPictureTaken = false;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
      ),
    );

    controller = CameraController(
      cameras[1],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
      fps: 30,
    );

    controller.initialize().then((_) {
      if (!mounted) return;
      startFaceDetection();
      // controller.setZoomLevel(1.4);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            print("Camera Access Denied");
            break;
          default:
            // Handle other errors here.
            print(e.code);
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _faceDetector.close();
    controller.dispose();
    super.dispose();
  }

  void startFaceDetection() {
    controller.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final faces = await detectFaces(image);
        setState(() {
          _faces = faces;
        });
        if (faces.isNotEmpty) {
          final face = faces.first;
          if (face.headEulerAngleY!.abs() < 10 &&
              face.headEulerAngleZ!.abs() < 10) {
            setState(() {
              _isUserLookingAtCamera = true;
            });
            takePicture(); // Trigger picture taking when the user is looking at the camera
          } else {
            setState(() {
              _isUserLookingAtCamera = false;
            });
          }
        }
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<List<Face>> detectFaces(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    // Get image rotation
    final InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(
                controller.description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: planeData,
    );

    // final inputImageData = InputImageData(
    //   size: imageSize,
    //   imageRotation: imageRotation,
    //   inputImageFormat: inputImageFormat,
    //   planeData: planeData,
    // );

    // InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return await _faceDetector.processImage(inputImage);
  }

  // Mark course attendance for student
  Future<dynamic> markStudentCourseAttendance(image) async {
    // Get student name
    final name =
        context.read<StudentsPageProvider>().studentProfile["student_name"];

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: "$name.jpg")
    });

    final response = await Dio().post(
      "${baseurl}student/attendance/class",
      queryParameters: {"id": widget.classId},
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      // Dispose of the camera controller
      controller.dispose();

      // Pop the screen and return to student's dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const StudentPage(),
        ),
        (route) => false,
      );

      // Successfully enrolled the face
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: response.data["detail"],
      );
      print("Class attendance successfully marked");

      return response.data;
    } else {
      // Dispose of the camera controller
      controller.dispose();

      // Pop the screen and return to student's dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const StudentPage(),
        ),
        (route) => false,
      );

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: response.data["detail"],
      );
      print("Failed to mark attendance: ${response.data["detail"]}");
    }
  }

  // Mark lecturer course attendance
  Future<dynamic> markLecturerCourseAttendance(image) async {
    // Get student name
    final name =
        context.read<LecturerPageProvider>().lecturerProfile["lecturer_name"];

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: "$name.jpg")
    });

    final response = await Dio().post(
      "${baseurl}lecturer/attendance/class",
      queryParameters: {"id": widget.classId},
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      // Dispose of the camera controller
      controller.dispose();

      // Pop the screen and return to student's dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LecturerPage(),
        ),
        (route) => false,
      );

      // Successfully enrolled the face
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: response.data["detail"],
      );
      print("Class attendance successfully marked");

      return response.data;
    } else {
      // Dispose of the camera controller
      controller.dispose();

      // Pop the screen and return to student's dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LecturerPage(),
        ),
        (route) => false,
      );

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: response.data["detail"],
      );
      print("Failed to mark attendance: ${response.data["detail"]}");
    }
  }

  void takePicture() async {
    if (_isPictureTaken) return; // Prevent multiple pictures

    _isPictureTaken = true;

    final XFile imageFile = await controller.takePicture();
    final File image = File(imageFile.path);

    // Get an instance of the shared preferences
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    String? user = localStorage.getString("page");

    if (_isUserLookingAtCamera) {
      if (user == "lecturer") {
        await markLecturerCourseAttendance(image);
      } else if (user == "student") {
        await markStudentCourseAttendance(image);
      }
    } else {
      // Prompt the user to look at the camera
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Attention",
        text: "Please look directly at the camera to capture your image.",
        onConfirmBtnTap: () {
          // Start the face detection again
          Navigator.of(context).pop(); // Close the alert
          _isPictureTaken = false; // Allow another attempt
          startFaceDetection(); // Retry face detection
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return controller.value.isInitialized
        ? Center(
            child: Container(
              height: height * 0.65,
              width: width * 0.78,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      CameraPreview(controller),
                      if (_faces.isNotEmpty)
                        CustomPaint(
                          painter: FaceMeshPainter(
                              _faces, controller.value.previewSize!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}

class FaceMeshPainter extends CustomPainter {
  final List<Face> faces;
  final Size previewSize;

  FaceMeshPainter(this.faces, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Face face in faces) {
      final boundingBox = face.boundingBox;

      //Log bounding box details
      print("Drawing bounding box at: ${boundingBox.left}, ${boundingBox.top}");

      canvas.drawRect(
        Rect.fromLTWH(
          boundingBox.left * size.width / previewSize.width,
          boundingBox.top * size.height / previewSize.height,
          boundingBox.width * size.width / previewSize.width,
          boundingBox.height * size.height / previewSize.height,
        ),
        paint,
      );

      // Draw face landmarks
      for (FaceLandmark? landmark in face.landmarks.values) {
        if (landmark != null) {
          canvas.drawCircle(
            Offset(
              landmark.position.x * size.width / previewSize.width,
              landmark.position.y * size.height / previewSize.height,
            ),
            2.0,
            Paint()..color = Colors.blue,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
