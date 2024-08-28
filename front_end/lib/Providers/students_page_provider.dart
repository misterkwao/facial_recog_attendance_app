// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Pages/login.dart';
import 'package:student_attendance_app/Pages/reset_password.dart';
import 'package:student_attendance_app/Pages/student_page.dart';

import '../Auth/api.dart';
import '../Pages/otp_page.dart';

class StudentsPageProvider with ChangeNotifier {
  Map _studentProfile = {};
  List _studentCourses = [];
  var _upcomingClasses;
  String _resetId = '';

  Map get studentProfile => _studentProfile;
  List get studentCourses => _studentCourses;
  get upcomingClasses => _upcomingClasses;
  String get resetId => _resetId;

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }

  // Login student
  Future<dynamic> loginStudent(BuildContext context, Map details) async {
    // Simulate login
    await Future.delayed(const Duration(seconds: 2));

    // Check if internet is available
    if (await _checkInternetConnection()) {
      try {
        Dio().options.contentType = Headers.formUrlEncodedContentType;
        var response = await Dio().post(
          "${baseurl}student_auth/login",
          data: details,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => true,
          ),
        );
        if (response.statusCode == 200) {
          accessToken = response.data["access_token"];

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const StudentPage(),
            ),
            (route) => false,
          );
          return response.data;
        } else {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: "Error",
              text: "Invalid credentials.");
        }
      } on DioException {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Failed to connect to server. Please try again later.");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
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
        print(e.message);
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

  // Forgot password
  Future<dynamic> forgotPasswordEmailCheck(
      BuildContext context, Map details) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().post(
        "${baseurl}student_auth/forgot-password",
        data: details,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        // Get reset id and save it
        _resetId = response.data["reset_id"];
        notifyListeners();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OtpPage(),
          ),
        );
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "An email has been sent to your registered email address.");
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Email does not exist in the student's database");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Verify the sent OTP
  Future<dynamic> verifyOTP(BuildContext context, Map detail) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().post(
        "${baseurl}student_auth/verify-code",
        queryParameters: {"reset_id": _resetId},
        data: detail,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordPage(),
          ),
        );
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "OTP succesfully verified.");
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Invalid OTP");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Verify the sent OTP
  Future<dynamic> sendNewPassword(BuildContext context, Map detail) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().patch(
        "${baseurl}student_auth/reset-password",
        queryParameters: {"reset_id": _resetId},
        data: json.encode(detail),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "Password successfully changed.");
      } else {
        print(response);
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Oops",
            text: "An error occurred.");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }
}
