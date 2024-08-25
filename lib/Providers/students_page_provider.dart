// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Pages/login.dart';

import '../Auth/api.dart';

class StudentsPageProvider with ChangeNotifier {
  Map _studentProfile = {};
  List _studentCourses = [];
  var _upcomingClasses;

  Map get studentProfile => _studentProfile;
  List get studentCourses => _studentCourses;
  get upcomingClasses => _upcomingClasses;

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }

  // Fetch necessary information to be able to display page
  Future fetchDetails(BuildContext context) async {
    if (await _checkInternetConnection()) {
      try {
        Map studentProfile = await getStudentProfileFromApi();
        // check if credentials has expired
        if (studentProfile["detail"] == "Could not validate credentials") {
          QuickAlert.show(
              barrierDismissible: false,
              context: context,
              type: QuickAlertType.error,
              title: "Session Expired",
              text: "Your session has expired. Please log in again.",
              onConfirmBtnTap: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );

                // Get shared preferences and set each to empty
                final SharedPreferences localStorage =
                    await SharedPreferences.getInstance();

                //Clear the shared preferences
                localStorage.clear();
              });
        }

        List fetchedCourses = await getStudentCoursesFromApi();
        var fetchedUpcomingClasses = await getStudentsUpcomingClassesFromApi();

        if (studentProfile.isNotEmpty) {
          _studentProfile = studentProfile;
          _studentCourses = fetchedCourses;
          _upcomingClasses = fetchedUpcomingClasses;

          notifyListeners();
        }
      } on DioException catch (e) {
        // QuickAlert.show(
        //     context: context,
        //     type: QuickAlertType.error,
        //     title: "Error",
        //     text: e.message);
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Get student profile
  Future<dynamic> getStudentProfileFromApi() async {
    var url = "${baseurl}student";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data["profile"];
    } else {
      return response.data;
    }
  }

  //Get student courses
  Future<List<dynamic>> getStudentCoursesFromApi() async {
    var url = "${baseurl}student";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data["profile"]["allowed_courses"];
    } else {
      return response.data;
    }
  }

  // Get student upcoming classes
  Future<dynamic> getStudentsUpcomingClassesFromApi() async {
    var url = "${baseurl}student";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data["upcoming_classes"];
    } else {
      return response.data;
    }
  }
}
