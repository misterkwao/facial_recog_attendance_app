// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Pages/lecturer_page.dart';
import 'package:student_attendance_app/Pages/otp_page.dart';

import '../Auth/api.dart';
import '../Constants/lecturer_constants.dart';
import '../Pages/login.dart';
import '../Pages/reset_password.dart';

class LecturerPageProvider with ChangeNotifier {
  List _lecturerClassLocations = [];
  List _lecturerCourses = [];
  List _lecturerUpcomingClasses = [];
  List _lecturerClassStatistics = [];
  Map _lecturerProfile = {};
  String _resetId = '';
  var _lecturerNotifications;

  List get lecturerClassLocations => _lecturerClassLocations;
  List get lecturerCourses => _lecturerCourses;
  List get lecturerUpcomingClasses => _lecturerUpcomingClasses;
  List get lecturerClassStatistics => _lecturerClassStatistics;
  Map get lecturerProfile => _lecturerProfile;
  String get resetId => _resetId;
  get lecturerNotifications => _lecturerNotifications;

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Login lecturer
  Future<dynamic> loginLecturer(BuildContext context, Map details) async {
    // Simulate login
    await Future.delayed(const Duration(seconds: 2));

    // Check if internet is available
    if (await _checkInternetConnection()) {
      try {
        Dio().options.contentType = Headers.formUrlEncodedContentType;
        var response = await Dio().post(
          "${baseurl}lecturer_auth/login",
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
              builder: (context) => const LecturerPage(),
            ),
            (route) => false,
          );
          return response.data;
        } else {
          print(response);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Invalid credentials.",
          );
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
        Map fetchedProfile = await getProfileFromApi();
        // check if credentials has expired
        if (fetchedProfile["detail"] == "Could not validate credentials") {
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

        List fetchedClassLocations = await getClassLocationsFromApi();
        List fetchedCourses = await getLecturerCoursesFromApi();
        List fetchedUpcomingClasses = await getUpcomingClassesFromApi();
        List fetchedClassStatistics = await getClassStatisticsFromApi();
        var fetchedNotifications = await getNotificationsFromApi();

        if (fetchedClassLocations.isNotEmpty) {
          _lecturerProfile = fetchedProfile;
          _lecturerCourses = fetchedCourses;
          _lecturerClassLocations = fetchedClassLocations;
          _lecturerUpcomingClasses = fetchedUpcomingClasses;
          _lecturerClassStatistics = fetchedClassStatistics;
          _lecturerNotifications = fetchedNotifications;

          print(_lecturerClassStatistics);

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

  //Method to create an upcoming class
  Future<void> createUpcomingClass(
      Map lecturerDetails, BuildContext context) async {
    if (await _checkInternetConnection()) {
      await createUpcomingClassToApi(lecturerDetails, context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to delete an upcoming class
  Future<void> deleteUpcomingClass(BuildContext context) async {
    if (await _checkInternetConnection()) {
      await deleteUpcomingClassFromApi(context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Get lecturer profile
  Future<dynamic> getProfileFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var url = "${baseurl}lecturer";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return response.data;
    }
  }

  // Get all class locations
  Future<dynamic> getClassLocationsFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    // Get class locations after logging in
    var response = await Dio().get(
      "${baseurl}lecturer/classes/class-locations",
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data["class_locations"];
    } else {
      return response.data;
    }
  }

  // Get lecturers courses
  Future<dynamic> getLecturerCoursesFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().get(
      "${baseurl}lecturer",
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data["allowed_courses"];
    } else {
      return response.data;
    }
  }

  // Get all upcoming classes
  Future<dynamic> getUpcomingClassesFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().get(
      "${baseurl}lecturer/classes/current-classes",
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data["current_classes"];
    } else {
      return response.data;
    }
  }

  Future<dynamic> getClassStatisticsFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().get(
      "${baseurl}lecturer/classes/statistics",
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return response.data;
    }
  }

  // Create a new upcoming class
  Future<dynamic> createUpcomingClassToApi(
      Map details, BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().post(
      "${baseurl}lecturer/classes/class",
      data: json.encode(details),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        validateStatus: (status) => true,
      ),
    );

    // Check if the operation was successful
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success!",
          text: "Class created successfully!");
    } else {
      Navigator.of(context).pop();
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error!",
          text: "Failed to create class. Please try again.");
    }
  }

  // Delete an upcoming class
  Future<dynamic> deleteUpcomingClassFromApi(BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().delete(
      "${baseurl}lecturer/classes/class",
      queryParameters: {
        "id": _lecturerUpcomingClasses[selectedUpcomingClass]["_id"]
      },
      options: Options(
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Class successfully deleted.",
      );
    } else {
      Navigator.of(context).pop();
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Ooops!",
          text: "Failed to delete class.");
    }
  }

  // Forgot password
  Future<dynamic> forgotPasswordEmailCheck(
      BuildContext context, Map details) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().post(
        "${baseurl}lecturer_auth/forgot-password",
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
        print(response);
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Email does not exist in the lecturer's database");
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
        "${baseurl}lecturer_auth/verify-code",
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
        "${baseurl}lecturer_auth/reset-password",
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
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Oops",
            text: "An error occurred");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Update upcoming class
  Future<dynamic> updateUpcomingClass(
      var details, BuildContext context, String id) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().patch(
        "${baseurl}lecturer/classes/class",
        queryParameters: {"id": id},
        data: json.encode(details),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "Class details updated successfully.");
      } else {
        Navigator.of(context).pop();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Failed to update class details. Please try again.");
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Get lecturer notifications
  Future<dynamic> getNotificationsFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var url = "${baseurl}lecturer";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data["notifications"];
    } else {
      return response.data;
    }
  }

  // Set notification is_read to false
  Future<dynamic> readNotification(
      BuildContext context, String notificationId) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().patch(
        "${baseurl}lecturer/update-notification",
        queryParameters: {"id": notificationId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: "Bearer $accessToken",
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        print("success");
      } else {
        print(response);
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
