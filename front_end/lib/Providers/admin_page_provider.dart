// ignore_for_file: prefer_final_fields, use_build_context_synchronously, unrelated_type_equality_checks, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Pages/admin_page.dart';

import '../Admin/widgets/all_classlocs.dart';
import '../Admin/widgets/lecturer_widgets.dart';
import '../Admin/widgets/student_widgets.dart';
import '../Auth/api.dart';
import '../Pages/login.dart';
import '../Pages/otp_page.dart';
import '../Pages/reset_password.dart';

class AdminPageProvider with ChangeNotifier {
  Map _adminProfile = {};
  List _allLecturers = [];
  List _allStudents = [];
  List _classLocations = [];
  String _resetId = '';

  Map get adminProfile => _adminProfile;
  List get allLecturers => _allLecturers;
  List get allStudents => _allStudents;
  List get classLocations => _classLocations;
  String get resetId => _resetId;

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Login lecturer
  Future<dynamic> loginAdmin(BuildContext context, Map details) async {
    // Simulate login
    await Future.delayed(const Duration(seconds: 2));

    // Check if internet is available
    if (await _checkInternetConnection()) {
      try {
        Dio().options.contentType = Headers.formUrlEncodedContentType;
        var response = await Dio().post(
          "${baseurl}admin_auth/login",
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
              builder: (context) => const AdminPage(),
            ),
            (route) => false,
          );
          return response.data;
        } else {
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
        Map adminProfile = await getAdminProfileFromApi();
        // check if credentials has expired
        if (adminProfile["detail"] == "Could not validate credentials") {
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
        List fetchedLecturers = await getAllLecturersFromApi();
        List fetchedStudents = await getAllStudentsFromApi();

        if (fetchedClassLocations.isNotEmpty) {
          _classLocations = fetchedClassLocations;
          _allLecturers = fetchedLecturers;
          _allStudents = fetchedStudents;
          _adminProfile = adminProfile;
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

  //Method to create a class location
  Future<void> createClassLocation(
      Map classLocation, BuildContext context) async {
    if (await _checkInternetConnection()) {
      await createClassToApi(classLocation, context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to delete a class location
  Future<void> deleteClassLocation(BuildContext context) async {
    if (await _checkInternetConnection()) {
      await deleteClassFromApi(context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to create a lecturer
  Future<void> createLecturer(Map lecturerDetails, BuildContext context) async {
    if (await _checkInternetConnection()) {
      await createLecturerToApi(lecturerDetails, context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to delete a lecturer
  Future<void> deleteLecturer(BuildContext context) async {
    if (await _checkInternetConnection()) {
      await deleteLecturerFromApi(context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to create a student
  Future<void> createStudent(Map studentDetials, BuildContext context) async {
    if (await _checkInternetConnection()) {
      await createStudentToApi(studentDetials, context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  Future<void> updateStudent(
      Map studentDetials, String id, BuildContext context) async {
    if (await _checkInternetConnection()) {
      await updateStudentDetailsToApi(studentDetials, id, context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  //Method to delete a student
  Future<void> deleteStudent(BuildContext context) async {
    if (await _checkInternetConnection()) {
      await deleteStudentFromApi(context);
      fetchDetails(context);
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "No Internet Connection",
          text: "Please check your internet connection and try again.");
    }
  }

  // Get all the class locations
  Future<dynamic> getClassLocationsFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    // Get class locations after logging in
    var response = await Dio().get(
      "${baseurl}admin/user-manangement/class",
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

  // Create a class location
  Future<dynamic> createClassToApi(
      Map classLocationDetails, BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().post(
      "${baseurl}admin/user-manangement/class",
      data: json.encode(classLocationDetails),
      options: Options(
        contentType: 'application/json',
        headers: {
          HttpHeaders.authorizationHeader: 'bearer $accessToken',
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Class Location created successfully",
      );

      return response.data;
    } else {
      return response.data;
    }
  }

  //Delete a class location
  Future<dynamic> deleteClassFromApi(BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().delete(
      "${baseurl}admin/user-manangement/class",
      queryParameters: {"id": _classLocations[selectedClassLoc]["_id"]},
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
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Class Location deleted successfully",
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to delete class location",
      );
    }
  }

  // Get admin details
  Future<dynamic> getAdminProfileFromApi() async {
    var url = "${baseurl}admin";
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

  // Get all lecturers
  Future<dynamic> getAllLecturersFromApi() async {
    var url = "${baseurl}admin/user-manangement/all";
    var response = await Dio().get(url,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
          validateStatus: (status) => true,
        ));
    if (response.statusCode == 200) {
      return response.data["lecturers"];
    } else {
      return response.data;
    }
  }

  // Create a lecturer
  Future<dynamic> createLecturerToApi(
      Map lecturerDetails, BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().post(
      "${baseurl}admin/user-manangement/lecturer",
      data: json.encode(lecturerDetails),
      options: Options(
        contentType: 'application/json',
        headers: {
          HttpHeaders.authorizationHeader: 'bearer $accessToken',
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Class Location created successfully",
      );

      return response.data;
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Error",
        text: "Failed to create class location successfully",
      );
    }
  }

  //Delete a lecturer
  Future<dynamic> deleteLecturerFromApi(BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().delete(
      "${baseurl}admin/user-manangement/lecturer",
      queryParameters: {"id": _allLecturers[selectedIndex]["owner"]},
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
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Class Location deleted successfully",
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to delete class location successfully",
      );
    }
  }

  //Get all students
  Future<dynamic> getAllStudentsFromApi() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    // Get class locations after logging in
    var response = await Dio().get(
      "${baseurl}admin/user-manangement/all",
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      return response.data["students"];
    } else {
      return response.data;
    }
  }

  // Create a student
  Future<dynamic> createStudentToApi(
      Map studentDetails, BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().post(
      '${baseurl}admin/user-manangement/student',
      data: studentDetails,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        validateStatus: (status) => true,
      ),
    );
    if (response.statusCode == 200) {
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Student created successfully",
      );
    } else {
      print(response.data);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to create student successfully",
      );
    }
  }

  // Delete a student
  Future<dynamic> deleteStudentFromApi(BuildContext context) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    var response = await Dio().delete(
      "${baseurl}admin/user-manangement/student",
      queryParameters: {"id": _allStudents[selectedStudentIndex]["owner"]},
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken",
          "content-type": "application/json"
        },
        responseType: ResponseType.json,
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Student deleted successfully",
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to delete student successfully",
      );
    }
  }

  // Update student details
  Future<dynamic> updateStudentDetailsToApi(
      Map details, String id, BuildContext context) async {
    var url = "${baseurl}admin/user-manangement/student";
    var response = await Dio().patch(
      url,
      queryParameters: {
        "id": id,
      },
      data: details,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: "bearer $accessToken",
        },
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      // Pop modal sheet
      Navigator.of(context).pop();

      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Student details updated successfully");
    } else {
      print(response.data);
    }
  }

  // Forgot password
  Future<dynamic> forgotPasswordEmailCheck(
      BuildContext context, Map details) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (await _checkInternetConnection()) {
      var response = await Dio().post(
        "${baseurl}admin_auth/forgot-password",
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
        "${baseurl}admin_auth/verify-code",
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
        "${baseurl}admin_auth/reset-password",
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
}
