// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../Student/scan.dart';

class MarkAttendance extends StatefulWidget {
  final String classId;
  const MarkAttendance({required this.classId, super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

bool markAttendance = false;

class _MarkAttendanceState extends State<MarkAttendance> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.8,
                alignment: Alignment.center,
                child: !markAttendance
                    ? LottieBuilder.network(
                        "https://lottie.host/0013d07a-726b-4fbb-8556-dfd6b8521ce2/5OV98R3tSe.json",
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return CircularProgressIndicator(
                              color: Colors.red[700]);
                        },
                      )
                    : ScanFace(classId: widget.classId),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Scan your",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "face and mark",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "attendance",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                splashColor: Colors.black,
                onTap: () {
                  setState(() {
                    markAttendance = !markAttendance;
                  });
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const ScanFace(),
                  //   ),
                  // );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.8,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(1, 99, 169, 1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(1, 1))
                      ]),
                  child: Text(
                    !markAttendance ? "Scan face" : "Cancel",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
