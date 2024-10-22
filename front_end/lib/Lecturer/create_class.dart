// ignore_for_file: avoid_unnecessary_containers, avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

import '../Admin/widgets/admin_widgets.dart';

import '../Pages/login.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({super.key});

  @override
  State<CreateClass> createState() => _CreateClassState();
}

Widget textfield(IconData icon, TextEditingController controller) {
  return TextFormField(
    cursorColor: Colors.black,
    controller: controller,
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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

final formKey = GlobalKey<FormState>();

// int courseLevel = 100;
// int courseSemester = 1;

class _CreateClassState extends State<CreateClass> {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController courseTitle = TextEditingController();
  TextEditingController courseLevel = TextEditingController();
  TextEditingController courseSemester = TextEditingController();
  TextEditingController testLink = TextEditingController();

  String startTime = "";
  String endTime = "";

  Widget dateField(TextEditingController controller) {
    return TextFormField(
      enabled: false,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: const Icon(Icons.date_range_rounded),
      ),
    );
  }

  // void pickDate(TextEditingController controller) async {
  //   await DatePicker.showDateTimePicker(
  //     context,
  //     showTitleActions: true,
  //     locale: LocaleType.en,
  //     minTime: DateTime.now(),
  //     maxTime: DateTime(2024, 08, 23, 10, 15),
  //     onChanged: (time) {
  //       print(time.toUtc().toIso8601String());
  //     },
  //     onConfirm: (time) {
  //       setState(() {
  //         controller.text = DateFormat('hh:mm     dd-MM-yyyy').format(time);
  //       });
  //     },
  //   );
  // }

  String? selectedClass;
  bool classSelected = false;

  Map classMapping = {
    "longitude": 0,
    "latitude": 0,
  };

  Widget classListPicker() {
    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => DropdownButtonFormField<String>(
        isExpanded: true,
        alignment: Alignment.centerRight,
        elevation: 2,
        value: selectedClass,
        decoration: InputDecoration(labelText: "--Select a class location--"),
        onChanged: (value) {
          setState(() {
            selectedClass = value;
            classSelected = true;
          });
          print(classMapping);
        },
        items: value.lecturerClassLocations.map((item) {
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            onTap: () => setState(() {
              classMapping = {
                "longitude": item["location"]["longitude"],
                "latitude": item["location"]["latitude"],
              };
            }),
            value: item["class_name"],
            child: Text(item["class_name"]!),
          );
        }).toList(),
      ),
    );
  }

  String? selectedCourse;
  bool courseSelected = false;

  Widget courseListPicker() {
    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: "--Select a course--"),
        isExpanded: true,
        alignment: Alignment.centerRight,
        elevation: 2,
        value: selectedCourse,
        onChanged: (value) {
          setState(() {
            selectedCourse = value;
            courseSelected = true;
          });
        },
        items: value.lecturerCourses.map((item) {
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            onTap: () => setState(() {
              courseTitle.text = item["course_title"];
              courseLevel.text = (item["level"]).toString();
              courseSemester.text = (item["semester"]).toString();
            }),
            value: item["course_title"],
            child: Text(item["course_title"]!),
          );
        }).toList(),
      ),
    );
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
            "Please fill in the blanks to create a new class",
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
                const Text("Course Title"),
                const SizedBox(height: 10),
                courseListPicker(),
                // textfield(Icons.abc, courseTitle),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            const Text("Course Level"),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: false,
                              controller: courseLevel,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey[300],
                                suffixIcon:
                                    const Icon(Icons.date_range_rounded),
                              ),
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
                            TextFormField(
                              enabled: false,
                              controller: courseSemester,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey[300],
                                suffixIcon:
                                    const Icon(Icons.date_range_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Class Location"),
                const SizedBox(height: 10),
                classListPicker(),
                const SizedBox(height: 20),
                const Text("Start Time"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: dateField(startDate)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(83, 178, 246, 1))),
                        onPressed: () async {
                          await DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            locale: LocaleType.en,
                            minTime: DateTime.now(),
                            maxTime: DateTime(2024, 12, 31, 00, 00),
                            onChanged: (time) {
                              print(time.toUtc().toIso8601String());
                            },
                            onConfirm: (time) {
                              setState(() {
                                startDate.text =
                                    DateFormat('HH:mm     dd-MM-yyyy')
                                        .format(time);
                                startTime = time.toUtc().toIso8601String();
                              });
                            },
                          );
                        },
                        child: const Text(
                          "Pick",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                const Text("End Time"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: dateField(endDate)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(83, 178, 246, 1))),
                        onPressed: () async {
                          await DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            locale: LocaleType.en,
                            minTime: DateTime.now(),
                            maxTime: DateTime(2024, 12, 31, 00, 00),
                            onChanged: (time) {
                              print(time.toUtc().toIso8601String());
                            },
                            onConfirm: (time) {
                              setState(() {
                                endDate.text =
                                    DateFormat('HH:mm     dd-MM-yyyy')
                                        .format(time);
                                endTime = time.toUtc().toIso8601String();
                              });
                            },
                          );
                        },
                        child: const Text(
                          "Pick",
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
                SizedBox(height: 20),
                Text("Test link"),
                const SizedBox(height: 10),
                textfield(Icons.analytics_outlined, testLink),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isloading = false;
                        });
                      },
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
                              }
                              setState(() {
                                isloading = true;
                              });

                              if (classSelected) {
                                final details = {
                                  "course_title": courseTitle.text,
                                  "course_level": int.parse(courseLevel.text),
                                  "course_semester_level":
                                      int.parse(courseSemester.text),
                                  "class_name": selectedClass,
                                  "location": classMapping,
                                  "start_time": startTime,
                                  "end_time": endTime,
                                  "test_link": testLink.text
                                };

                                print(details);

                                try {
                                  await context
                                      .read<LecturerPageProvider>()
                                      .createUpcomingClass(details, context);

                                  setState(() {
                                    isloading = false;
                                  });
                                } on DioException catch (e) {
                                  setState(() {
                                    isloading = false;
                                  });
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: "Error!",
                                      text: e.message);
                                }
                              } else {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    title: "Sorry!",
                                    text:
                                        "Please select a class location where the class will take place.");
                              }
                              // setState(() {
                              //   courseSemester = 1;
                              //   courseLevel = 100;
                              // });
                            },
                            child: const Text("Create Class"),
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
