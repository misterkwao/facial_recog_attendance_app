// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Pages/login.dart';
import 'package:student_attendance_app/Pages/otp_page.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';
import 'package:student_attendance_app/Providers/students_page_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum User { admin, student, lecturer }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Form key
  final thisformKey = GlobalKey<FormState>();

  String emailForgot = "";

  User? _character = User.student;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    Widget forgotPassword(double width) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: width < 700
              ? const EdgeInsets.symmetric(horizontal: 20)
              : width < 1500
                  ? const EdgeInsets.symmetric(horizontal: 80)
                  : const EdgeInsets.symmetric(horizontal: 160),
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  "assets/images/privatedata.gif",
                  height: 200,
                ),
                const SizedBox(height: 50),
                const Text(
                  "Forgot Password ?",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Don't worry, enter the email address associated with the account. You will receive a one-time-password to be able to reset your password.",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                    // color: Color.fromRGBO(83, 178, 246, 1),
                  ),
                ),
                const SizedBox(height: 50),
                Form(
                  key: thisformKey,
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 255, 194, 194),
                                  width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 255, 194, 194),
                                  width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 216, 216, 216),
                                    width: 2)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(187, 164, 196, 251),
                                    width: 2)),
                            suffixIcon: const Icon(Icons.person,
                                color: Color.fromARGB(159, 158, 158, 158))),
                        onChanged: (value) {
                          setState(() {
                            emailForgot = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field cannot be empty";
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Radio<User>(
                                  activeColor: Colors.blueAccent,
                                  value: User.admin,
                                  groupValue: _character,
                                  onChanged: (value) => setState(
                                    () {
                                      _character = value;
                                    },
                                  ),
                                ),
                                const Text(
                                  "Admin",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio<User>(
                                  activeColor: Colors.blueAccent,
                                  value: User.student,
                                  groupValue: _character,
                                  onChanged: (value) => setState(
                                    () {
                                      _character = value;
                                    },
                                  ),
                                ),
                                const Text(
                                  "Student",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio<User>(
                                  activeColor: Colors.blueAccent,
                                  value: User.lecturer,
                                  groupValue: _character,
                                  onChanged: (value) => setState(
                                    () {
                                      _character = value;
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: const Text(
                                    "Lecturer",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      isloading
                          ? const CircularProgressIndicator(
                              color: Color.fromRGBO(83, 178, 246, 1),
                            )
                          : InkWell(
                              onTap: () async {
                                if (thisformKey.currentState!.validate()) {
                                  thisformKey.currentState!.save();

                                  setState(() {
                                    isloading = true;
                                  });

                                  Map details = {
                                    'email': emailForgot,
                                  };

                                  try {
                                    // Simulate sending email
                                    if (_character == User.student) {
                                      await context
                                          .read<StudentsPageProvider>()
                                          .forgotPasswordEmailCheck(
                                              context, details);

                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => const OtpPage(),
                                      //   ),
                                      // );

                                      // Set User resetting password to student
                                      setState(() {
                                        forgotUser = _character.toString();
                                        isloading = false;
                                      });
                                    } else if (_character == User.admin) {
                                      await context
                                          .read<AdminPageProvider>()
                                          .forgotPasswordEmailCheck(
                                              context, details);

                                      // Set User resetting password to admin
                                      setState(() {
                                        forgotUser = _character.toString();
                                        isloading = false;
                                      });
                                    } else {
                                      await context
                                          .read<LecturerPageProvider>()
                                          .forgotPasswordEmailCheck(
                                              context, details);

                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => const OtpPage(),
                                      //   ),
                                      // );

                                      // Set User resetting password to lecturer
                                      setState(() {
                                        forgotUser = _character.toString();
                                        isloading = false;
                                      });
                                    }
                                  } on DioException {
                                    setState(() {
                                      isloading = false;
                                    });
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: "Oops!",
                                        text: "An error occurred.");
                                  }
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: width,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Text(
                                  "Send",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return forgotPassword(width);
        } else if (constraints.maxWidth < 1500) {
          return forgotPassword(width);
        } else {
          return forgotPassword(width);
        }
      },
    );
  }
}
