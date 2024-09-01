import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../Admin/widgets/admin_widgets.dart';
import '../Admin/widgets/create_classloc.dart';

Widget userTally() {
  return Consumer<AdminPageProvider>(
    builder: (context, value, child) => Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300] ?? Colors.black),
            ),
            child: Column(
              children: [
                const Text(
                  "Total Students",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat'),
                ),
                Text(
                  (value.allStudents.length).toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 15),
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300] ?? Colors.black),
          ),
          child: Column(
            children: [
              const Text(
                "Total Lecturers",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat'),
              ),
              Text(
                (value.allLecturers.length).toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontSize: 15),
              )
            ],
          ),
        )),
      ],
    ),
  );
}

Widget createClassLoc(BuildContext context, double newheight, double newwidth) {
  return ElevatedButton(
      onPressed: () {
        modalSheet(context, 0.7, newwidth, newheight, const CreateClassLoc());
      },
      style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
      child: const Text(
        "Create Class Location",
        style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat Bold'),
      ));
}

Widget adminProfile(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;

  return Consumer<AdminPageProvider>(
    builder: (context, value, child) => SizedBox(
      width: width,
      child: Text(
        "Hi, ${value.adminProfile["username"]}",
        style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 25,
            fontFamily: 'Montserrat'),
      ),
    ),
  );
}
