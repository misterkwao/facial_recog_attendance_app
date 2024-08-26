// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Admin/lecturerfunc/course_widget.dart';
import '../../Pages/login.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/student_widgets.dart';

class Createlecturer extends StatefulWidget {
  const Createlecturer({super.key});

  @override
  State<Createlecturer> createState() => _CreatelecturerState();
}

final formKey = GlobalKey<FormState>();

int lecCourseLevel = 100;
int lecCourseSemester = 1;

int newLecturerCourse = 1;

List<Widget> courses = [
  CoursesWidget(
    index: 0,
    others: true,
  ),
];

final TextEditingController lecturerName = TextEditingController();
final TextEditingController lecturerEmail = TextEditingController();
final TextEditingController lecturerPassword = TextEditingController();
final TextEditingController lecturerCollege = TextEditingController();
final TextEditingController lecturerDepartment = TextEditingController();
List<int> courseLecturerLevel = [100];
List<int> courseLecturerSemester = [1];
List<TextEditingController> courseLecturerTitle = [TextEditingController()];
List<TextEditingController> courseLecturerCollege = [TextEditingController()];
List<TextEditingController> courseLecturerDepartment = [
  TextEditingController()
];

List<Map> allowedLecturerCourses = [];

class _CreatelecturerState extends State<Createlecturer> {
  void addController() {
    courseLecturerLevel.add(lecCourseLevel);
    courseLecturerSemester.add(lecCourseSemester);
    courseLecturerTitle.add(TextEditingController());
    courseLecturerCollege.add(TextEditingController());
    courseLecturerDepartment.add(TextEditingController());
  }

  void removeController() {
    courseLecturerLevel.removeLast();
    courseLecturerSemester.removeLast();
    courseLecturerTitle.removeLast();
    courseLecturerCollege.removeLast();
    courseLecturerDepartment.removeLast();
  }

  void toCourses() {
    for (int i = 0; i < courseLecturerTitle.length; i++) {
      allowedLecturerCourses.add({
        'level': courseLecturerLevel[i],
        'semester': courseLecturerSemester[i],
        'course_title': courseLecturerTitle[i].text,
        'college': courseLecturerCollege[i].text,
        'department': courseLecturerDepartment[i].text,
      });
    }
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
            "Please fill in the blanks to create a new lecturer",
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
                const Text("Lecturer name"),
                const SizedBox(height: 10),
                textfield(Icons.abc, lecturerName),
                const SizedBox(height: 20),
                const Text("Lecturer email"),
                const SizedBox(height: 10),
                textfield(Icons.email, lecturerEmail),
                const SizedBox(height: 20),
                const Text("Password"),
                const SizedBox(height: 10),
                textfield(Icons.lock, lecturerPassword),
                const Text("Lecturer college"),
                const SizedBox(height: 10),
                textfield(Icons.book_outlined, lecturerCollege),
                const Text("Lecturer department"),
                const SizedBox(height: 10),
                textfield(Icons.school_outlined, lecturerDepartment),
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
                        itemCount: courses.length,
                        itemBuilder: (context, index) => courses[index],
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
                                courses.add(CoursesWidget(
                                  index: newLecturerCourse,
                                  others: true,
                                ));
                                newLecturerCourse++;
                              });
                              print(courses);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                              child: const Icon(Icons.add),
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (courses.length > 1)
                            InkWell(
                              onTap: () {
                                if (courses.length > 1) {
                                  setState(() {
                                    courses.removeLast();
                                    removeController();
                                    newLecturerCourse--;
                                  });
                                }

                                print(courses);
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
                // TextFormField(
                //   maxLines: 10,
                //   cursorColor: Colors.black,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(20),
                //         borderSide: BorderSide.none),
                //     filled: true,
                //     fillColor: Colors.grey[300],
                //   ),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return "Field cannot be empty";
                //     }
                //     return null;
                //   },
                // ),
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
                            color: Color.fromRGBO(83, 178, 246, 1),
                          )
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

                                // Map controller to the map of courses to be submitted
                                toCourses();

                                // Map all details of the lecturer
                                final Map lecturerDetails = {
                                  "lecturer_name": lecturerName.text,
                                  "lecturer_email": lecturerEmail.text,
                                  "password": lecturerPassword.text,
                                  "allowed_courses": allowedLecturerCourses,
                                  "lecturer_college": lecturerCollege.text,
                                  "lecturer_department":
                                      lecturerDepartment.text,
                                };

                                print(lecturerDetails);

                                try {
                                  await context
                                      .read<AdminPageProvider>()
                                      .createLecturer(lecturerDetails, context);

                                  setState(() {
                                    isloading = false;

                                    // Clear all controllers
                                    lecturerEmail.clear();
                                    lecturerName.clear();
                                    lecturerPassword.clear();
                                    lecturerCollege.clear();
                                    lecturerDepartment.clear();
                                    allowedLecturerCourses.clear();

                                    // Reinitialize the controllers
                                    courseLecturerLevel = [100];
                                    courseLecturerSemester = [1];
                                    courseLecturerTitle = [
                                      TextEditingController()
                                    ];
                                    courseLecturerCollege = [
                                      TextEditingController()
                                    ];
                                    courseLecturerDepartment = [
                                      TextEditingController()
                                    ];

                                    // Remove all courses except first one
                                    courses.removeRange(1, courses.length);

                                    // Reset the new student course counter
                                    newLecturerCourse = 1;

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
                            },
                            child: const Text("Create Lecturer"),
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
    // Dispose controllers in courseLecturerTitle, keeping the first one
    if (courseLecturerTitle.length > 1) {
      for (var i = 0; i < courseLecturerTitle.length; i++) {
        courseLecturerTitle[i].dispose();
      }
    }

    // Dispose controllers in courseLecturerCollege, keeping the first one
    if (courseLecturerCollege.length > 1) {
      for (var i = 0; i < courseLecturerCollege.length; i++) {
        courseLecturerCollege[i].dispose();
      }
    }

    // Dispose controllers in courseLecturerDepartment, keeping the first one
    if (courseLecturerDepartment.length > 1) {
      for (var i = 0; i < courseLecturerDepartment.length; i++) {
        courseLecturerDepartment[i].dispose();
      }
    }

    // Dispose controllers in courseLecturerLevel, keeping the first one
    if (courseLecturerLevel.length > 1) {
      for (var i = 0; i < courseLecturerLevel.length; i++) {
        courseLecturerLevel.removeAt(i);
      }
    }

    // Dispose controllers in courseLecturerSemester, keeping the first one
    if (courseLecturerSemester.length > 1) {
      for (var i = 0; i < courseLecturerSemester.length; i++) {
        courseLecturerSemester.removeAt(i);
      }
    }

    super.dispose();
  }
}
