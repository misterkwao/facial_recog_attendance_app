// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../Providers/admin_page_provider.dart';
import '../Providers/lecturer_page_provider.dart';
import '../Providers/students_page_provider.dart';
import 'login.dart';
import 'otp_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Form key
  final formKey = GlobalKey<FormState>();

  String initPass = "";
  String secondPass = "";

  String password = "";

  Widget resetPassword(double width, double height) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      padding: width < 700
          ? const EdgeInsets.symmetric(horizontal: 20)
          : width < 1500
              ? const EdgeInsets.symmetric(horizontal: 80)
              : const EdgeInsets.symmetric(horizontal: 160),
      width: width,
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset(
              "assets/images/resetpasssword.gif",
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Reset Password",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                // color: Color.fromRGBO(83, 178, 246, 1),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your new password",
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    // controller: emailForgot,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    onChanged: (value) {
                      setState(() {
                        initPass = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Field cannot be empty";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Re-enter password",
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    // controller: emailForgot,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    onChanged: (value) {
                      setState(() {
                        secondPass = value;
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Field cannot be empty";
                      } else {
                        if (secondPass != initPass) {
                          return "Passwords do not match";
                        }
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 30),
                  isloading
                      ? Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: Color.fromRGBO(83, 178, 246, 1),
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              setState(() {
                                isloading = true;
                              });

                              Map details = {
                                "new_password": password,
                              };
                              try {
                                if (forgotUser == "User.student") {
                                  await context
                                      .read<StudentsPageProvider>()
                                      .sendNewPassword(context, details);

                                  setState(() {
                                    isloading = false;
                                  });
                                } else if (forgotUser == "User.lecturer") {
                                  await context
                                      .read<LecturerPageProvider>()
                                      .sendNewPassword(context, details);

                                  setState(() {
                                    isloading = false;
                                  });
                                } else if (forgotUser == "User.admin") {
                                  await context
                                      .read<AdminPageProvider>()
                                      .sendNewPassword(context, details);

                                  setState(() {
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

                              setState(() {
                                isloading = false;
                              });
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: width,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              "Reset",
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
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
              ),
              body: resetPassword(width, height));
        } else if (constraints.maxWidth < 1500) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
              ),
              body: resetPassword(width, height));
        } else {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
              ),
              body: resetPassword(width, height));
        }
      },
    );
  }
}
