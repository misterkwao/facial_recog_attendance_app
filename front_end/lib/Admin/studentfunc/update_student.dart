// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Admin/widgets/student_widgets.dart';
import '../../Providers/admin_page_provider.dart';
import '../../Pages/login.dart';
import '../widgets/admin_widgets.dart';

class UpdateStudent extends StatefulWidget {
  const UpdateStudent({super.key});

  @override
  State<UpdateStudent> createState() => _UpdateStudentState();
}

class _UpdateStudentState extends State<UpdateStudent> {
  final formKey = GlobalKey<FormState>();

  late String yearEnrolled;
  late String currentLevel;
  late String currentSemester;
  late String is_face_enrolled;

  Widget editText(IconData icon, bool enable, String? text) {
    return TextFormField(
      // controller: controller,
      cursorColor: Colors.black,
      enabled: enable,
      initialValue: text,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: Icon(icon),
      ),
      onChanged: (value) => setState(() {
        if (text == yearEnrolled) {
          yearEnrolled = value;
        } else if (text == currentLevel) {
          currentLevel = value;
        } else if (text == currentSemester) {
          currentSemester = value;
        } else if (text == is_face_enrolled) {
          is_face_enrolled = value;
        }
      }),
      validator: (value) {
        if (value!.isEmpty) {
          return "Field cannot be empty";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List students = Provider.of<AdminPageProvider>(context).allStudents;

    yearEnrolled = (students[selectedStudentIndex]["year_enrolled"]).toString();
    currentLevel =
        (students[selectedStudentIndex]["student_current_level"]).toString();
    currentSemester =
        (students[selectedStudentIndex]["student_current_semester"]).toString();
    is_face_enrolled =
        (students[selectedStudentIndex]["is_face_enrolled"]).toString();
  }

  // @override
  // void initState() {
  //   super.initState();

  //   List students = Provider.of<AdminPageProvider>(context).allStudents;

  //   yearEnrolled = (students[selectedStudentIndex]["year_enrolled"]).toString();
  //   currentLevel =
  //       (students[selectedStudentIndex]["student_current_level"]).toString();
  //   currentSemester =
  //       (students[selectedStudentIndex]["student_current_semester"]).toString();
  //   is_face_enrolled =
  //       (students[selectedStudentIndex]["is_face_enrolled"]).toString();
  // }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    List students = Provider.of<AdminPageProvider>(context).allStudents;
    String ownerId = students[selectedStudentIndex]["owner"];

    final String name = students[selectedStudentIndex]["student_name"];

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
                editText(Icons.person_3_rounded, false, name),
                const SizedBox(height: 20),
                const Text("Year enrolled"),
                const SizedBox(height: 10),
                editText(Icons.numbers_rounded, true, yearEnrolled),
                const SizedBox(height: 20),
                const Text("Current level"),
                const SizedBox(height: 10),
                editText(Icons.numbers_rounded, true, currentLevel),
                const SizedBox(height: 20),
                const Text("Current semester"),
                const SizedBox(height: 10),
                editText(Icons.numbers_rounded, true, currentSemester),
                const SizedBox(height: 20),
                const Text("Face enrolled"),
                const SizedBox(height: 10),
                editText(Icons.numbers_rounded, true, is_face_enrolled),
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
                                  "year_enrolled": yearEnrolled,
                                  "student_current_level": currentLevel,
                                  "student_current_semester": currentSemester,
                                  "is_face_enrolled": is_face_enrolled
                                };

                                print(details);

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
