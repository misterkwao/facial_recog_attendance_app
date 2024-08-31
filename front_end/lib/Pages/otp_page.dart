// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';
import 'package:student_attendance_app/Providers/students_page_provider.dart';

import 'login.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

String forgotUser = "";

class _OtpPageState extends State<OtpPage> {
  // Form key
  final thisformKey = GlobalKey<FormState>();

  int otp = 0;

  Widget pinCode(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 5,
      enableActiveFill: true,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 400),
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(20),
        fieldHeight: 60,
        fieldWidth: 60,
        inactiveColor: Colors.grey[400],
        activeColor: Colors.blue,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.grey[300],
        selectedColor: Colors.grey[300],
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Field cannot be empty";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autoDismissKeyboard: true,
      onCompleted: (value) async {
        setState(() {
          isloading = true;
          otp = int.parse(value);
        });

        Map details = {"code": otp};
        try {
          if (forgotUser == "User.student") {
            await context
                .read<StudentsPageProvider>()
                .verifyOTP(context, details);

            setState(() {
              isloading = false;
            });
          } else if (forgotUser == "User.lecturer") {
            await context
                .read<LecturerPageProvider>()
                .verifyOTP(context, details);

            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => const ResetPasswordPage(),
            //   ),
            // );

            setState(() {
              isloading = false;
            });
          } else if (forgotUser == "User.admin") {
            await context.read<AdminPageProvider>().verifyOTP(context, details);

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
      },
    );
  }

  Widget otpWidget(double height, double width) {
    return Container(
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
            const SizedBox(height: 60),
            Image.asset(
              "assets/images/pincode.gif",
              height: 250,
            ),
            const SizedBox(height: 40),
            const Text(
              "Verification code",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                // color: Color.fromRGBO(83, 178, 246, 1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Please check your email, we have sent you a verification code.",
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            Form(
              key: thisformKey,
              child: Column(
                children: [
                  pinCode(context),
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

                              Map details = {"code": otp};
                              try {
                                if (forgotUser == "User.student") {
                                  await context
                                      .read<StudentsPageProvider>()
                                      .verifyOTP(context, details);

                                  setState(() {
                                    isloading = false;
                                  });
                                } else if (forgotUser == "User.lecturer") {
                                  await context
                                      .read<LecturerPageProvider>()
                                      .verifyOTP(context, details);

                                  setState(() {
                                    isloading = false;
                                  });
                                } else if (forgotUser == "User.admin") {
                                  await context
                                      .read<AdminPageProvider>()
                                      .verifyOTP(context, details);

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
            body: otpWidget(height, width),
          );
        } else if (constraints.maxWidth < 1500) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
            ),
            body: otpWidget(height, width),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
            ),
            body: otpWidget(height, width),
          );
        }
      },
    );
  }
}
