// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously, avoid_print
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

import '../Auth/api.dart';
import '../Auth/base_client.dart';
import '../Pages/student_page.dart';
import 'admin_page.dart';
import 'lecturer_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// void StudentAuth() async {
//   var
// }

var authcredential = {
  "username": usernameController.text,
  "password": passwordController.text
};

bool isloading = false;

// Role taken to check through database
String loginrole = "Student";

// Form key
final formKey = GlobalKey<FormState>();

// Controllers for input in logging in
final TextEditingController usernameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

// Change password visibility
bool isVisible = true;

// Get admin profile
Future<dynamic> adminprofile(String api) async {
  var url = baseurl + api;
  var response = await Dio().get(url,
      options: Options(
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
        validateStatus: (status) => true,
      ));
  if (response.statusCode == 200) {
    return response;
  } else {
    // throw Exception(response.data.toString());
    // throw exception
  }
}

// Get student profile
Future<dynamic> studentProfile(String api) async {
  var url = baseurl + api;
  var response = await Dio().get(url,
      options: Options(
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: "bearer $accessToken"},
        validateStatus: (status) => true,
      ));
  if (response.statusCode == 200) {
    return response;
  } else {
    // throw Exception(response.data.toString());
    // throw exception
  }
}

//Get list of upcoming classes after logging in
Future<dynamic> allLecturerUpcomingClasses(String api) async {
  var response = await Dio().get(
    baseurl + api,
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

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final lecturerPageProvider = Provider.of<LecturerPageProvider>(context);
    final adminPageProvider = Provider.of<AdminPageProvider>(context);

    Widget loginButton(
        BuildContext context, String role, String label, double width) {
      return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              setState(() {
                isloading = true;
              });

              // Get an instance of the shared preferences
              final SharedPreferences localStorage =
                  await SharedPreferences.getInstance();

              //Check role to sign person in
              if (role == "Student") {
                try {
                  var response = await DioClient()
                      .postLogin("student_auth/login", authcredential, context);

                  // Save the access token on the user's device and page logged in
                  localStorage.setString(
                      "access_token", response["access_token"]);
                  localStorage.setString("page", "student");

                  // Set access token on the user's device and page
                  accessToken = response["access_token"];

                  // Log user in
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const StudentPage(),
                  ));
                  usernameController.clear();
                  passwordController.clear();

                  setState(() {
                    isloading = false;
                  });
                } on DioException catch (e) {
                  setState(() {
                    isloading = false;
                  });
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Ooops!",
                      text: e.message);
                }
              } else if (role == "Lecturer") {
                try {
                  // Check details and log lecturer in
                  var response = await DioClient().postLogin(
                      "lecturer_auth/login", authcredential, context);

                  // Save the access token on the user's device and page logged in
                  localStorage.setString(
                      "access_token", response["access_token"]);
                  localStorage.setString("page", "lecturer");

                  // Set access token on the user's device and page
                  accessToken = response["access_token"];

                  //Get class locations after signing in and save in lecturer list for class
                  await lecturerPageProvider.fetchDetails(context);

                  print(
                      "classes : ${lecturerPageProvider.lecturerClassLocations}");

                  // Log user in
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LecturerPage(),
                  ));
                  usernameController.clear();
                  passwordController.clear();
                  setState(() {
                    isloading = false;
                  });
                } on DioException catch (e) {
                  setState(() {
                    isloading = false;
                  });
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Ooops!",
                      text: e.message);
                }
              } else {
                try {
                  var response = await DioClient()
                      .postLogin("admin_auth/login", authcredential, context);
                  print(response);

                  // Save the access token on the user's device and page logged in
                  localStorage.setString(
                      "access_token", response["access_token"]);
                  localStorage.setString("page", "admin");

                  // Set access token on the user's device and page
                  accessToken = response["access_token"];

                  //Fetch admin profile, students , lecturers and class locations
                  await adminPageProvider.fetchDetails(context);

                  // Log admin user in
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const AdminPage(),
                  ));

                  usernameController.clear();
                  passwordController.clear();
                  setState(() {
                    isloading = false;
                  });
                } on DioException catch (e) {
                  setState(() {
                    isloading = false;
                  });
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Ooops!",
                      text: e.message);
                }
              }
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    Widget roleSelect(
        double height, double width, String imagePath, String name) {
      return Tooltip(
        message: name,
        child: InkWell(
          onTap: () {
            setState(() {
              loginrole = name;
            });
            print(loginrole);
          },
          child: Stack(children: [
            Container(
                // height: height * 0.05,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  loginrole == name
                      ? const BoxShadow(
                          color: Colors.black, spreadRadius: 1, blurRadius: 10)
                      : const BoxShadow(color: Colors.white)
                ]),
                child: ClipOval(
                  child: LottieBuilder.asset(
                    imagePath,
                    height: height * 0.06,
                  ),
                )),
          ]),
        ),
      );
    }

    Widget detailScreen(double width) {
      return Container(
        alignment: Alignment.center,
        height: screenHeight,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: width * 0.10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "W E L C O M E !",
                    style: TextStyle(
                      fontFamily: "Kanit",
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // color: Color.fromRGBO(83, 178, 246, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Lottie.asset(
                  "assets/images/loginlottie.json",
                  errorBuilder: (context, error, stackTrace) {
                    return const CircularProgressIndicator(
                        color: Color.fromRGBO(83, 178, 246, 1));
                  },
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.3,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const Text("Email address"),
              const SizedBox(height: 10),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.black,
                      controller: usernameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[300],
                          suffixIcon: const Icon(Icons.person)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter a username";
                        } else if (!RegExp(r'^(?![_.])').hasMatch(value)) {
                          return "Cannot begin with _ or .";
                        } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+$')
                            .hasMatch(value)) {
                          return "Can contain only _ and . as special characters";
                        } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+(?<![._])$')
                            .hasMatch(value)) {
                          return "Cannot end with _ or .";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password"),
                        Text(
                          "Forgot password?",
                          style:
                              TextStyle(color: Color.fromRGBO(83, 178, 246, 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: isVisible,
                      cursorColor: Colors.black,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[300],
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            isVisible = !isVisible;
                          }),
                          child: isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter a password";
                        } else if (!RegExp(r'^(?=.{6,}$)').hasMatch(value)) {
                          return "Cannot be less than 6 characters";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Who are you signing in as?",
                        )),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            roleSelect(screenHeight, screenWidth,
                                "assets/images/admin.json", "Admin"),
                            SizedBox(width: screenWidth * 0.1),
                            roleSelect(screenHeight, screenWidth,
                                "assets/images/student.json", "Student"),
                            SizedBox(width: screenWidth * 0.1),
                            roleSelect(screenHeight, screenWidth,
                                "assets/images/lecturer.json", "Lecturer")
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    isloading
                        ? const Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: Color.fromRGBO(83, 178, 246, 1),
                            ),
                          )
                        : loginButton(context, loginrole, "Login", screenWidth),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Container(
                width: width,
                child: const FittedBox(
                  fit: BoxFit.cover,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "© 2024  ",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "This software is a product of Kwao Technologies. All rights reserved.",
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return detailScreen(screenWidth);
        } else {
          return Container(
            width: screenWidth,
            height: screenHeight,
            child: Row(
              children: [
                Stack(children: [
                  Container(
                    width: screenWidth * 0.50,
                    height: screenHeight,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset("assets/images/adminlogin2.jpeg")),
                  ),
                  Container(
                    height: screenHeight,
                    width: screenWidth * 0.5,
                    decoration: const BoxDecoration(color: Colors.black38),
                  )
                ]),
                detailScreen(screenWidth * 0.50),
              ],
            ),
          );
        }
      }),
    );
  }
}
