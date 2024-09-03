import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Admin/widgets/admin_widgets.dart';
import 'package:student_attendance_app/Constants/lecturer_constants.dart';
import 'package:student_attendance_app/Pages/login.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

class UpdateUpcomingClass extends StatefulWidget {
  const UpdateUpcomingClass({super.key});

  @override
  State<UpdateUpcomingClass> createState() => _UpdateUpcomingClassState();
}

class _UpdateUpcomingClassState extends State<UpdateUpcomingClass> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  List upcomingClasses = [];
  late String className;
  late String testLink;
  Map classMapping = {};

  @override
  void initState() {
    super.initState();

    upcomingClasses = Provider.of<LecturerPageProvider>(context, listen: false)
        .lecturerUpcomingClasses;

    startTimeController = TextEditingController(
        text: DateFormat("HH:mm     dd-MM-yyyy").format(DateTime.parse(
            upcomingClasses[selectedUpcomingClass]["start_time"])));
    endTimeController = TextEditingController(
        text: DateFormat("HH:mm     dd-MM-yyyy").format(DateTime.parse(
            upcomingClasses[selectedUpcomingClass]["end_time"])));

    classMapping = {
      "longitude": upcomingClasses[selectedUpcomingClass]["location"]
          ["longitude"],
      "latitude": upcomingClasses[selectedUpcomingClass]["location"]
          ["latitude"],
    };

    className = upcomingClasses[selectedUpcomingClass]["class_name"];
    testLink = upcomingClasses[selectedUpcomingClass]["test_link"];

    print(className);
    print(testLink);
    print(classMapping);
  }

  Widget editText(IconData icon, bool enable) {
    return TextFormField(
      // controller: controller,
      cursorColor: Colors.black,
      enabled: enable,
      initialValue: testLink,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: Icon(icon),
      ),
      onChanged: (value) => setState(() {
        testLink = value;
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

  Widget classListPicker() {
    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => DropdownButtonFormField<String>(
        isExpanded: true,
        alignment: Alignment.centerRight,
        elevation: 2,
        value: className,
        // decoration: InputDecoration(labelText: "--Select a class location--"),
        onChanged: (value) {
          setState(() {
            className = value!;
            // classMapping["longitude"] =
            // classSelected = true;
          });
        },
        items: value.lecturerClassLocations.map((item) {
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            onTap: () => setState(() {
              // classMapping = {
              //   "longitude": item["location"]["longitude"],
              //   "latitude": item["location"]["latitude"],
              // };
              classMapping["longitude"] = item["location"]["longitude"];
              classMapping["latitude"] = item["location"]["latitude"];
              print("class mapping: $classMapping");
            }),
            value: item["class_name"],
            child: Text(item["class_name"]!),
          );
        }).toList(),
      ),
    );
  }

  Widget dateField(TextEditingController classTime) {
    return TextFormField(
      enabled: false,
      controller: classTime,
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    Future<dynamic> startTimePicker() async {
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
            startTimeController.text =
                DateFormat('HH:mm     dd-MM-yyyy').format(time);
            startTimeController.text = time.toUtc().toIso8601String();
          });
        },
      );
    }

    Future<dynamic> endTimePicker() async {
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
            endTimeController.text =
                DateFormat('HH:mm     dd-MM-yyyy').format(time);
            endTimeController.text = time.toUtc().toIso8601String();
          });
        },
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        Text(
          "Please edit the fields you want to update",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Consumer<LecturerPageProvider>(
            builder: (context, value, child) => Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Class location"),
                  classListPicker(),
                  // editText(Icons.abc, true, className),
                  const SizedBox(height: 20),
                  const Text("Start Time"),
                  Container(
                    width: width,
                    child: Row(
                      children: [
                        Expanded(child: dateField(startTimeController)),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromRGBO(83, 178, 246, 1))),
                          onPressed: () async {
                            await startTimePicker();
                            print(startTimeController.text);
                          },
                          child: const Text(
                            "Pick",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("End Time"),
                  Container(
                    width: width,
                    child: Row(
                      children: [
                        Expanded(child: dateField(endTimeController)),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromRGBO(83, 178, 246, 1))),
                          onPressed: () async {
                            await endTimePicker();
                            print(endTimeController.text);
                          },
                          child: const Text(
                            "Pick",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Test link"),
                  editText(Icons.link, true),
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
                          ? CircularProgressIndicator(
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

                                Map details = {
                                  "class_name": className,
                                  "location": classMapping,
                                  "start_time": startTimeController.text,
                                  "end_time": endTimeController.text,
                                  "test_link": testLink
                                };

                                print(details);

                                // Update data here
                                try {
                                  await context
                                      .read<LecturerPageProvider>()
                                      .updateUpcomingClass(
                                          details,
                                          context,
                                          upcomingClasses[selectedUpcomingClass]
                                              ["_id"]);

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
                              },
                              child: Text("Update"),
                            )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
