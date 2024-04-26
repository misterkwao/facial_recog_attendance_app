import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../adminpage.dart';
import '../lecturerpage.dart';
import '../onboardingscreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

Widget loginButton(
    BuildContext context, String role, String label, double width) {
  return Align(
    alignment: Alignment.center,
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              if (role == "student") {
                return const OnboardingScreen();
              } else if (role == "lecturer") {
                return const LecturerPage();
              } else {
                return const AdminPage();
              }
            },
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(83, 178, 246, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ),
  );
}

// Role taken to check through database
String loginrole = "student";

// Change password visibility
bool isVisible = true;

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget roleSelect(
        double height, double width, String imagePath, String name) {
      return Tooltip(
        message: name,
        child: InkWell(
          onTap: () {
            setState(() {
              loginrole = name;
            });
          },
          child: Stack(children: [
            Container(
                // height: height * 0.05,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  loginrole == name
                      ? const BoxShadow(
                          color: Color.fromRGBO(83, 178, 246, 1),
                          spreadRadius: 1,
                          blurRadius: 10)
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
        padding: EdgeInsets.symmetric(horizontal: width * 0.15),
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
                    "Welcome back!",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(83, 178, 246, 1)),
                  ),
                ),
              ),
              const Align(
                  alignment: Alignment.center,
                  child: Text("Sign in to scan your face!")),
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
              const Text("Your email"),
              const SizedBox(height: 10),
              TextField(
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[300],
                    suffixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Password"),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.25),
                    const Text(
                      "Forgot password?",
                      style: TextStyle(color: Color.fromRGBO(83, 178, 246, 1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: isVisible,
                cursorColor: Colors.black,
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
                          : const Icon(Icons.visibility_off)),
                ),
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
                          "assets/images/admin.json", "admin"),
                      SizedBox(width: screenWidth * 0.1),
                      roleSelect(screenHeight, screenWidth,
                          "assets/images/student.json", "student"),
                      SizedBox(width: screenWidth * 0.1),
                      roleSelect(screenHeight, screenWidth,
                          "assets/images/lecturer.json", "lecturer")
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              loginButton(context, loginrole, "Login", screenWidth),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        body: kIsWeb
            ? Container(
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
                            child:
                                Image.asset("assets/images/adminlogin2.jpeg")),
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
              )
            : detailScreen(screenWidth));
  }
}
