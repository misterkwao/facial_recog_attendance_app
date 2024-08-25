// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/students_page_provider.dart';

import '../Auth/api.dart';
import '../main.dart';

class ScanFace extends StatefulWidget {
  final String classId;
  const ScanFace({required this.classId, super.key});

  @override
  State<ScanFace> createState() => _ScanFaceState();
}

class _ScanFaceState extends State<ScanFace> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras[1],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
      fps: 30,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
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

    takePicture();
  }

  void markCourseAttendance(image) async {
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
      // Successfully enrolled the face
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: response.data["detail"],
      );
      print("Class attendance successfully marked");
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: response.data["detail"],
      );
      print("Failed to mark attendance: ${response.data["detail"]}");
    }
  }

  void takePicture() {
    Timer(const Duration(seconds: 5), () async {
      await controller.takePicture().then((value) {
        if (mounted) {
          final File image = File(value.path);
          markCourseAttendance(image);
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   final CameraController? cameraController = controller;

  //   // App state changed before we got the chance to initialize.
  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     return;
  //   }

  //   if (state == AppLifecycleState.inactive) {
  //     cameraController.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     _initializeCameraController(cameraController.description);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   // appBar: AppBar(
    //   //   title: const Text('Scan Face'),
    //   //   centerTitle: true,
    //   //   backgroundColor: Colors.white,
    //   // ),
    //   body: controller.value.isInitialized
    //       ? CameraPreview(controller)
    //       : Container(),
    // );
    return controller.value.isInitialized
        ? CameraPreview(controller)
        : Container();
  }
}
