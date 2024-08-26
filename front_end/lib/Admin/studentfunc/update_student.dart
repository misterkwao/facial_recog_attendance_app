// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Admin/widgets/student_widgets.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Pages/login.dart';
import '../../auth/api.dart';
import '../widgets/admin_widgets.dart';

class UpdateStudent extends StatefulWidget {
  const UpdateStudent({super.key});

  @override
  State<UpdateStudent> createState() => _UpdateStudentState();
}

class _UpdateStudentState extends State<UpdateStudent> {
  final formKey = GlobalKey<FormState>();

  Widget editText(
      TextEditingController controller, IconData icon, bool enable) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      enabled: enable,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Field cannot be empty";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    List students = Provider.of<AdminPageProvider>(context).allStudents;
    String ownerId = students[selectedStudentIndex]["owner"];

    final TextEditingController studentName = TextEditingController(
        text: (students[selectedStudentIndex]["student_name"]));
    final TextEditingController yearEnrolled = TextEditingController(
        text: (students[selectedStudentIndex]["year_enrolled"]).toString());
    final TextEditingController currentLevel = TextEditingController(
        text: (students[selectedStudentIndex]["student_current_level"])
            .toString());
    final TextEditingController currentSemester = TextEditingController(
        text: (students[selectedStudentIndex]["student_current_semester"])
            .toString());
    final TextEditingController isFaceEnrolled = TextEditingController(
        text: (students[selectedStudentIndex]["is_face_enrolled"]).toString());

    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please edit the fields you want to update",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student name"),
                editText(studentName, Icons.person_3_rounded, false),
                const SizedBox(height: 20),
                const Text("Year enrolled"),
                const SizedBox(height: 10),
                editText(yearEnrolled, Icons.numbers_rounded, true),
                const SizedBox(height: 20),
                const Text("Current level"),
                const SizedBox(height: 10),
                editText(currentLevel, Icons.numbers_rounded, true),
                const SizedBox(height: 20),
                const Text("Current semester"),
                const SizedBox(height: 10),
                editText(currentSemester, Icons.numbers_rounded, true),
                const SizedBox(height: 20),
                const Text("Face enrolled"),
                const SizedBox(height: 10),
                editText(isFaceEnrolled, Icons.numbers_rounded, true),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.redAccent),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    isloading
                        ? const CircularProgressIndicator(
                            color: Color.fromRGBO(83, 178, 246, 1))
                        : ElevatedButton(
                            style: const ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromRGBO(83, 178, 246, 1)),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                setState(() {
                                  isloading = true;
                                });

                                Map details = {
                                  "year_enrolled": yearEnrolled.text,
                                  "student_current_level": currentLevel.text,
                                  "student_current_semester":
                                      currentSemester.text,
                                  "is_face_enrolled": isFaceEnrolled.text
                                };

                                try {
                                  await context
                                      .read<AdminPageProvider>()
                                      .updateStudent(details, ownerId, context);

                                  setState(() {
                                    isloading = false;
                                  });
                                } on DioException catch (e) {
                                  setState(() {
                                    isloading = false;
                                  });
                                  print(e);
                                }
                              }
                            },
                            child: const Text("Update"),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
