// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';

import '../widgets/student_widgets.dart';
import 'create_lecturer.dart';

class CoursesWidget extends StatefulWidget {
  final bool others;
  int index;
  CoursesWidget({required this.others, required this.index, super.key});

  @override
  State<CoursesWidget> createState() => _CoursesWidgetState();
}

// final TextEditingController lecturerCourseTitle = TextEditingController();
// final TextEditingController lecturerCourseCollege = TextEditingController();
// final TextEditingController lecturerCourseDepartment = TextEditingController();

class _CoursesWidgetState extends State<CoursesWidget> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey[400], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      const Text("Course Level"),
                      const SizedBox(height: 10),
                      DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 100,
                            child: Text("100"),
                          ),
                          DropdownMenuItem(
                            value: 200,
                            child: Text("200"),
                          ),
                          DropdownMenuItem(
                            value: 300,
                            child: Text("300"),
                          ),
                          DropdownMenuItem(
                            value: 400,
                            child: Text("400"),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        elevation: 1,
                        // padding: const EdgeInsets.symmetric(horizontal: 15),
                        isExpanded: true,

                        value: lecCourseLevel,
                        onChanged: (value) {
                          setState(() {
                            courseLecturerLevel[widget.index] = value!;
                            lecCourseLevel = courseLecturerLevel[widget.index];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: width * 0.1),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      const Text("Course Semester"),
                      const SizedBox(height: 10),
                      DropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text("1st"),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("2nd"),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        elevation: 1,
                        // padding: const EdgeInsets.symmetric(horizontal: 15),
                        isExpanded: true,

                        value: lecCourseSemester,
                        onChanged: (value) {
                          setState(() {
                            courseLecturerSemester[widget.index] = value!;
                            lecCourseSemester =
                                courseLecturerSemester[widget.index];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Course Title"),
          textfield(Icons.abc_rounded, courseLecturerTitle[widget.index]),
          widget.others
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text("College"),
                    textfield(
                        Icons.abc_rounded, courseLecturerCollege[widget.index]),
                    const SizedBox(height: 20),
                    const Text("Department"),
                    textfield(Icons.abc_rounded,
                        courseLecturerDepartment[widget.index]),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
