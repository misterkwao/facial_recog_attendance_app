// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../Admin/widgets/admin_widgets.dart';
import '../Providers/students_page_provider.dart';
import 'mark_attendance.dart';

class StudentUpcomingClass extends StatefulWidget {
  const StudentUpcomingClass({super.key});

  @override
  State<StudentUpcomingClass> createState() => _StudentUpcomingClassState();
}

class _StudentUpcomingClassState extends State<StudentUpcomingClass> {
  // Get current date and time
  DateTime now = DateTime.now();

  double distance = 0;

  // Function to check if student is within a 10 meter radius of the location
  Future<bool> isWithinLocationRadius(double latitude, double longitude) async {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: 0);
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print(
          '${position?.latitude.toString()}, ${position?.longitude.toString()}');
      setState(() {
        distance = Geolocator.distanceBetween(
          position!.latitude,
          position!.longitude,
          latitude,
          longitude,
        );
      });

      // Print the distance between the
      print(distance);
    });
    return distance <= 10.0;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Classses",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 10),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Consumer<StudentsPageProvider>(
              builder: (context, value, child) {
                if (value.upcomingClasses.runtimeType == String) {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.grey[300] ?? Colors.black),
                    ),
                    child: const Text(
                      "No Upcoming Classes",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const PageScrollPhysics(),
                    itemCount: value.upcomingClasses.length,
                    itemBuilder: (context, index) {
                      // Get the longitude and latitude where class is being held
                      final double classLatitude =
                          value.upcomingClasses[index]["location"]["latitude"];
                      final double classLongitude =
                          value.upcomingClasses[index]["location"]["longitude"];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              // Print the latitude and longitude of the class
                              print(
                                  "Latitude: $classLatitude, Longitude: $classLongitude");

                              // Check if current date and time is within specified range and route user
                              if (now.isAfter(DateTime.parse(value.upcomingClasses[index]
                                      ["start_time"])) &&
                                  now.isBefore(DateTime.parse(value
                                      .upcomingClasses[index]["end_time"]))) {
                                // Show bottom sheet to let user know you are checking location
                                showModalBottomSheet(
                                  barrierColor: Colors.black26,
                                  backgroundColor: Colors.white,
                                  // showDragHandle: true,
                                  sheetAnimationStyle:
                                      AnimationStyle(curve: Curves.easeIn),
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 410,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            modalDrag(width),
                                            Image.asset(
                                              "assets/images/map.gif",
                                              height: 150,
                                            ),
                                            const Text(
                                                "Making sure you are in class")
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                await Future.delayed(
                                    const Duration(seconds: 1));

                                // Check location of student
                                if (await isWithinLocationRadius(
                                    classLatitude, classLongitude)) {
                                  // Pop modal bottom sheet
                                  Navigator.pop(context);

                                  // Wait for the pop animation to complete
                                  await Future.delayed(
                                      const Duration(milliseconds: 200));

                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.confirm,
                                    title: "Attendance",
                                    text:
                                        "Mark attendance for ${value.upcomingClasses[index]["course_title"]}",

                                    // Navigate to mark attendance page
                                    onConfirmBtnTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MarkAttendance(
                                          classId: value.upcomingClasses[index]
                                              ["_id"],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Pop modal bottom sheet
                                  Navigator.pop(context);

                                  // Wait for the pop animation to complete
                                  await Future.delayed(
                                      const Duration(milliseconds: 200));

                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: "Sorry",
                                      text:
                                          "You are not in class and thus can't mark attendance.");
                                }
                              } else if (now.isBefore(DateTime.parse(value
                                  .upcomingClasses[index]["start_time"]))) {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: "Sorry",
                                    text: "The class has not started yet.");
                              } else if (now.isAfter(DateTime.parse(
                                  value.upcomingClasses[index]["end_time"]))) {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: "Sorry",
                                    text:
                                        "The time has passed and you missed the class.");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey[300] ?? Colors.black),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                      height: 50,
                                      child: VerticalDivider(
                                          color: Colors.blue, thickness: 5)),
                                  Expanded(
                                      child: Column(
                                    children: [
                                      Text(
                                          value.upcomingClasses[index]
                                              ["class_name"],
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13)),
                                      Text(
                                          value.upcomingClasses[index]
                                              ["course_title"],
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13)),
                                      Text(
                                          "Start: ${DateFormat('HH:mm     dd/MM/yyyy').format(DateTime.parse(value.upcomingClasses[index]["start_time"]))}",
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13)),
                                      Text(
                                          "End: ${DateFormat('HH:mm     dd/MM/yyyy').format(DateTime.parse(value.upcomingClasses[index]["end_time"]))}",
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13)),
                                    ],
                                  )),
                                  Image.asset(
                                    "assets/images/facial-recognition-icon.png",
                                    height: 40,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
