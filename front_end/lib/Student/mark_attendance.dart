// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

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
        child: ScanFace(classId: widget.classId),
      ),
    );
  }
}
