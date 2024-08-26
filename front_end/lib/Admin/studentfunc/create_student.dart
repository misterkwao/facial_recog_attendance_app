// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Pages/login.dart';
import '../lecturerfunc/course_widget.dart';
import '../lecturerfunc/create_lecturer.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/student_widgets.dart';

class CreateStudent extends StatefulWidget {
  const CreateStudent({super.key});

  @override
  State<CreateStudent> createState() => _CreateStudentState();
}

final formKey = GlobalKey<FormState>();

int newStudentCourse = 1;

List<Widget> studentCourses = [
  CoursesWidget(
    index: 0,
    others: false,
  ),
];

List<Map> firstSemester100 = [];
List<Map> secondSemester100 = [];
List<Map> firstSemester200 = [];
List<Map> secondSemester200 = [];
List<Map> firstSemester300 = [];
List<Map> secondSemester300 = [];
List<Map> firstSemester400 = [];
List<Map> secondSemester400 = [];

final TextEditingController studentName = TextEditingController();
final TextEditingController studentMail = TextEditingController();
final TextEditingController studentPassword = TextEditingController();
final TextEditingController studentYearEnrolled = TextEditingController();
final TextEditingController studentCurrentLevel = TextEditingController();
final TextEditingController studentCurrentSemester = TextEditingController();
final TextEditingController studentCollege = TextEditingController();
final TextEditingController studentDepartment = TextEditingController();

List<Map> allowedStudentCourses = [];

class _CreateStudentState extends State<CreateStudent> {
  void addController() {
    courseLecturerLevel.add(100);
    courseLecturerSemester.add(1);
    courseLecturerTitle.add(TextEditingController());
  }

  void removeController() {
    courseLecturerLevel.removeLast();
    courseLecturerSemester.removeLast();
    courseLecturerTitle.removeLast();
  }

  void toCourses() {
    allowedStudentCourses.clear();
    for (int i = 0; i < courseLecturerTitle.length; i++) {
      allowedStudentCourses.add({
        'level': courseLecturerLevel[i],
        'semester': courseLecturerSemester[i],
        'course_title': courseLecturerTitle[i].text,
      });
    }
  }

  void toYears() {
    firstSemester100.clear();
    secondSemester100.clear();
    firstSemester200.clear();
    secondSemester200.clear();
    firstSemester300.clear();
    secondSemester300.clear();
    firstSemester400.clear();
    secondSemester400.clear();

    for (var i = 0; i < allowedStudentCourses.length; i++) {
      if (allowedStudentCourses[i]["level"] == 100 &&
          allowedStudentCourses[i]["semester"] == 1) {
        firstSemester100.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 100 &&
          allowedStudentCourses[i]["semester"] == 2) {
        secondSemester100.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 200 &&
          allowedStudentCourses[i]["semester"] == 1) {
        firstSemester200.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 200 &&
          allowedStudentCourses[i]["semester"] == 2) {
        secondSemester200.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 300 &&
          allowedStudentCourses[i]["semester"] == 1) {
        firstSemester300.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 300 &&
          allowedStudentCourses[i]["semester"] == 2) {
        secondSemester300.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 400 &&
          allowedStudentCourses[i]["semester"] == 1) {
        firstSemester400.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      } else if (allowedStudentCourses[i]["level"] == 400 &&
          allowedStudentCourses[i]["semester"] == 2) {
        secondSemester400.add({
          'course_title': allowedStudentCourses[i]['course_title'],
          'no_of_attendance': 0,
        });
      }
    }
  }

  bool validateCourses() {
    if (firstSemester100.isEmpty ||
        secondSemester100.isEmpty ||
        firstSemester200.isEmpty ||
        secondSemester200.isEmpty ||
        firstSemester300.isEmpty ||
        secondSemester300.isEmpty ||
        firstSemester400.isEmpty ||
        secondSemester400.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Please provide at least one course for each semester.",
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please fill in the blanks to create a new student",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student name"),
                const SizedBox(height: 10),
                textfield(Icons.abc, studentName),
                const SizedBox(height: 20),
                const Text("Student email"),
                const SizedBox(height: 10),
                textfield(Icons.email, studentMail),
                const SizedBox(height: 20),
                const Text("Password"),
                const SizedBox(height: 10),
                textfield(Icons.lock, studentPassword),
                const SizedBox(height: 20),
                const Text("Year enrolled"),
                const SizedBox(height: 10),
                textfield(Icons.numbers_rounded, studentYearEnrolled),
                const SizedBox(height: 20),
                const Text("Current Level"),
                const SizedBox(height: 10),
                textfield(Icons.numbers_rounded, studentCurrentLevel),
                const SizedBox(height: 20),
                const Text("Current Semester"),
                const SizedBox(height: 10),
                textfield(Icons.numbers_rounded, studentCurrentSemester),
                const SizedBox(height: 20),
                const Text("College of Student"),
                TextButton(
                    onPressed: () => print(studentCourses),
                    child: const Text("Print")),
                const SizedBox(height: 10),
                textfield(Icons.abc_rounded, studentCollege),
                const SizedBox(height: 20),
                const Text("Department of Student"),
                const SizedBox(height: 10),
                textfield(Icons.abc_rounded, studentDepartment),
                const SizedBox(height: 20),
                const Text("Allowed courses"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: studentCourses.length,
                        itemBuilder: (context, index) {
                          // if (studentCourses.isEmpty) {
                          //   return const Text("No courses added");
                          // } else {
                          //   return studentCourses[index];
                          // }
                          return studentCourses[index];
                        },
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                addController();
                                lecCourseLevel = 100;
                                lecCourseSemester = 1;
                                studentCourses.add(CoursesWidget(
                                  index: newStudentCourse,
                                  others: false,
                                ));
                                newStudentCourse++;
                              });

                              print(studentCourses);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                              child: const Icon(Icons.add),
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (studentCourses.length > 1)
                            InkWell(
                              onTap: () {
                                if (studentCourses.length > 1) {
                                  setState(() {
                                    removeController();
                                    studentCourses.removeLast();
                                    newStudentCourse--;
                                  });
                                }

                                print(studentCourses);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.red),
                                child: const Icon(Icons.remove),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
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

                                //Map individual controllers to list of map of allowed courses
                                toCourses();
                                print(
                                    "Allowed courses: $allowedStudentCourses");

                                print("Levels: $courseLecturerLevel");
                                print("Semesters: $courseLecturerSemester");

                                // Map the correct course years and semesters
                                toYears();

                                print(
                                    "100 $firstSemester100 \n $secondSemester100");
                                print(
                                    "200 $firstSemester200 \n $secondSemester200");
                                print(
                                    "300 $firstSemester300 \n $secondSemester300");
                                print(
                                    "400 $firstSemester400 \n $secondSemester400");

                                final List<Map> updatedCourses = [
                                  {
                                    "level": 100,
                                    "first_semester_courses": firstSemester100,
                                    "second_semester_courses":
                                        secondSemester100,
                                  },
                                  {
                                    "level": 200,
                                    "first_semester_courses": firstSemester200,
                                    "second_semester_courses":
                                        secondSemester200,
                                  },
                                  {
                                    "level": 300,
                                    "first_semester_courses": firstSemester300,
                                    "second_semester_courses":
                                        secondSemester300,
                                  },
                                  {
                                    "level": 400,
                                    "first_semester_courses": firstSemester400,
                                    "second_semester_courses":
                                        secondSemester400,
                                  },
                                ];

                                // Create a map of student details to be posted
                                final Map studentDetails = {
                                  'student_name': studentName.text,
                                  'student_email': studentMail.text,
                                  'year_enrolled':
                                      int.parse(studentYearEnrolled.text),
                                  'student_current_level':
                                      int.parse(studentCurrentLevel.text),
                                  "student_current_semester":
                                      int.parse(studentCurrentSemester.text),
                                  'password': studentPassword.text,
                                  'allowed_courses': updatedCourses,
                                  'is_face_enrolled': false,
                                  'student_college': studentCollege.text,
                                  'student_department': studentDepartment.text,
                                };

                                if (validateCourses()) {
                                  try {
                                    await context
                                        .read<AdminPageProvider>()
                                        .createStudent(studentDetails, context);

                                    setState(() {
                                      isloading = false;
                                      newStudentCourse = 1;

                                      // Remove all courses except first one
                                      studentCourses.removeRange(
                                          1, studentCourses.length);

                                      // Reinitialize the controllers
                                      courseLecturerLevel = [100];
                                      courseLecturerSemester = [1];
                                      courseLecturerTitle = [
                                        TextEditingController()
                                      ];

                                      // Clear all controllers
                                      studentName.clear();
                                      studentMail.clear();
                                      studentPassword.clear();
                                      studentYearEnrolled.clear();
                                      studentCurrentLevel.clear();
                                      studentCurrentSemester.clear();
                                      studentCollege.clear();
                                      studentDepartment.clear();
                                      allowedStudentCourses.clear();

                                      // Reset the new student course counter
                                      newStudentCourse = 1;

                                      // Clear the form
                                      formKey.currentState?.reset();
                                    });
                                  } on DioException catch (e) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: "Error",
                                        text: e.message);

                                    setState(() {
                                      isloading = false;
                                    });
                                  }
                                }

                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                            child: const Text("Create Student"),
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

  @override
  void dispose() {
    if (courseLecturerTitle.length > 1) {
      for (var i = 0; i < courseLecturerTitle.length; i++) {
        courseLecturerTitle[i].dispose();
      }
    }
    if (courseLecturerLevel.length > 1) {
      for (var i = 0; i < courseLecturerLevel.length; i++) {
        courseLecturerLevel.removeAt(i);
      }
    }
    if (courseLecturerSemester.length > 1) {
      for (var i = 0; i < courseLecturerSemester.length; i++) {
        courseLecturerSemester.remove(i);
      }
    }

    super.dispose();
  }
}
