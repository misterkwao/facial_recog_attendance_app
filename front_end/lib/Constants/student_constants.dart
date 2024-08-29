// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Admin/widgets/admin_widgets.dart';
import 'package:student_attendance_app/Providers/students_page_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../Student/mark_attendance.dart';

Widget profile(double width, double height) {
  return SizedBox(
    width: width,
    child: Consumer<StudentsPageProvider>(
      builder: (context, value, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, ${value.studentProfile["student_name"]}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300] ?? Colors.black)),
            child: Stack(
              children: [
                Container(
                  width: width,
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/images/Classroom.png',
                    height: 150,
                  ),
                ),
                Column(
                  children: [
                    Row(children: [
                      const Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Text(
                          "Level ${(value.studentProfile["student_current_level"]).toString()}")
                    ]),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(
                        Icons.bar_chart_outlined,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                          "Semester ${(value.studentProfile["student_current_semester"]).toString()}")
                    ]),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(
                        Icons.book_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(value.studentProfile["student_college"])
                    ]),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Text(value.studentProfile["student_department"])
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget allCourses(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height * 0.4;
  return Consumer<StudentsPageProvider>(
    builder: (context, value, child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "All Courses",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: value.studentCourses.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 25,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                int chosenLevel = index;
                modalSheet(context, 0.8, width, height,
                    semesterMenu(width, chosenLevel));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.grey[300] ?? Colors.black)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.view_list_sharp,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 15),
                    Text("Level: ${value.studentCourses[index]["level"]}")
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget semesterMenu(double width, int levelIndex) {
  return Consumer<StudentsPageProvider>(
    builder: (context, value, child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          modalDrag(width),
          const SizedBox(height: 20),
          Text(
            "Level ${(value.studentCourses[levelIndex]["level"]).toString()}",
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: Colors.black, fontSize: 25),
          ),
          const SizedBox(height: 25),
          const Row(
            children: [
              Icon(Icons.bar_chart_outlined, color: Colors.red),
              SizedBox(width: 15),
              Text(
                "Semester 1",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value
                  .studentCourses[levelIndex]["first_semester_courses"].length,
              itemBuilder: (context, index) => Container(
                  width: width,
                  margin: const EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.grey[300] ?? Colors.black)),
                  child: Row(
                    children: [
                      const SizedBox(
                          height: 50,
                          child: VerticalDivider(
                              color: Colors.blue, thickness: 5)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Course Title: ${value.studentCourses[levelIndex]["first_semester_courses"][index]["course_title"]}",
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No of attendances: ${(value.studentCourses[levelIndex]["first_semester_courses"][index]["no_of_attendance"]).toString()}",
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          const SizedBox(height: 25),
          const Row(
            children: [
              Icon(Icons.bar_chart_outlined, color: Colors.red),
              SizedBox(width: 15),
              Text(
                "Semester 2",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900),
              )
            ],
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value
                  .studentCourses[levelIndex]["second_semester_courses"].length,
              itemBuilder: (context, index) => Container(
                  width: width,
                  margin: const EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.grey[300] ?? Colors.black)),
                  child: Row(
                    children: [
                      const SizedBox(
                          height: 50,
                          child: VerticalDivider(
                              color: Colors.blue, thickness: 5)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Course Title: ${value.studentCourses[levelIndex]["second_semester_courses"][index]["course_title"]}",
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No of attendances: ${(value.studentCourses[levelIndex]["second_semester_courses"][index]["no_of_attendance"]).toString()}",
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget courses(double height, double width, BuildContext context) {
  var provider =
      Provider.of<StudentsPageProvider>(context, listen: false).studentProfile;

  int currentYear = 0;
  String currentSemester = "";

  switch (provider["student_current_level"]) {
    case 100:
      currentYear = 0;
      break;
    case 200:
      currentYear = 1;
      break;
    case 300:
      currentYear = 2;
      break;
    case 400:
      currentYear = 3;
      break;
  }

  switch (provider["student_current_semester"]) {
    case 1:
      currentSemester = "first_semester_courses";
      break;
    case 2:
      currentSemester = "second_semester_courses";
      break;
  }

  return Container(
    width: width,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300] ?? Colors.black)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Courses Registered",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Consumer<StudentsPageProvider>(
            builder: (context, value, child) => ListView.builder(
              shrinkWrap: true,
              physics: const PageScrollPhysics(),
              itemCount:
                  value.studentCourses[currentYear][currentSemester].length,
              itemBuilder: (context, index) => Column(
                children: [
                  const SizedBox(height: 15),
                  courseListTile(
                    value.studentCourses[currentYear][currentSemester][index]
                        ["course_title"],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}

Widget courseListTile(String course) {
  return Row(
    children: [
      const Icon(Icons.stop_circle_rounded),
      const SizedBox(width: 10),
      Text(course),
    ],
  );
}

Widget attendances(double width, int gridcount, BuildContext context) {
  var provider =
      Provider.of<StudentsPageProvider>(context, listen: false).studentProfile;

  int currentYear = 0;
  String currentSemester = "";

  switch (provider["student_current_level"]) {
    case 100:
      currentYear = 0;
      break;
    case 200:
      currentYear = 1;
      break;
    case 300:
      currentYear = 2;
      break;
    case 400:
      currentYear = 3;
      break;
  }

  switch (provider["student_current_semester"]) {
    case 1:
      currentSemester = "first_semester_courses";
      break;
    case 2:
      currentSemester = "second_semester_courses";
      break;
  }

  return SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attendances",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Consumer<StudentsPageProvider>(
                builder: (context, value, child) => GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridcount,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.9),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      value.studentCourses[currentYear][currentSemester].length,
                  itemBuilder: (context, index) {
                    // var level = value.studentProfile["student_current_level"];
                    // var semester =
                    //     value.studentProfile["student_current_semester"];

                    return attendanceAxis(
                        12.0,
                        (value.studentCourses[currentYear][currentSemester]
                                [index]["no_of_attendance"])
                            .toDouble(),
                        value.studentCourses[currentYear][currentSemester]
                            [index]["course_title"],
                        "${(value.studentCourses[currentYear][currentSemester][index]["no_of_attendance"]).toString()}/12");
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget attendanceAxis(
    double maxatten, double attendvalue, String course, String attendance) {
  return SfRadialGauge(axes: [
    RadialAxis(
      minimum: 0,
      maximum: maxatten,
      radiusFactor: 1,
      pointers: [
        RangePointer(
          animationDuration: 2000,
          enableAnimation: true,
          animationType: AnimationType.easeInCirc,
          cornerStyle: CornerStyle.bothCurve,
          value: attendvalue,
          color: Colors.red,
        )
      ],
      showTicks: false,
      showLabels: false,
      startAngle: 270,
      endAngle: 270,
      annotations: [
        GaugeAnnotation(
            widget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.centerRight,
              height: 110,
              width: 110,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      course,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      attendance,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ))
      ],
    ),
  ]);
}

// Widget upcomingClasses(double height, double width, BuildContext context) {
//   // Get current date and time
//   DateTime now = DateTime.now();

//   double distance = 0;

//   // Function to check if student is within a 10 meter radius of the location
//   Future<bool> isWithinLocationRadius(double latitude, double longitude) async {
//     LocationSettings locationSettings = const LocationSettings(
//         accuracy: LocationAccuracy.best, distanceFilter: 0);
//     StreamSubscription<Position> positionStream =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position? position) {
//       // print(
//       //     '${position?.latitude.toString()}, ${position?.longitude.toString()}');
//       distance = Geolocator.distanceBetween(
//         position!.latitude,
//         position!.longitude,
//         latitude,
//         longitude,
//       );

//       // Print the distance between the
//       print(distance);
//     });
//     return distance <= 10.0;
//   }

//   return SizedBox(
//     width: width,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Upcoming Classses",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w900,
//             fontSize: 16,
//           ),
//         ),
//         MediaQuery.removePadding(
//           context: context,
//           removeTop: true,
//           removeBottom: true,
//           child: Consumer<StudentsPageProvider>(
//             builder: (context, value, child) {
//               if (value.upcomingClasses.runtimeType == String) {
//                 return Container(
//                   alignment: Alignment.center,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.grey[300] ?? Colors.black),
//                   ),
//                   child: const Text(
//                     "No Upcoming Classes",
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 );
//               } else {
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const PageScrollPhysics(),
//                   itemCount: value.upcomingClasses.length,
//                   itemBuilder: (context, index) {
//                     // Get the longitude and latitude where class is being held
//                     final double classLatitude =
//                         value.upcomingClasses[index]["location"]["latitude"];
//                     final double classLongitude =
//                         value.upcomingClasses[index]["location"]["longitude"];

//                     return Column(
//                       children: [
//                         InkWell(
//                           onTap: () async {
//                             // Print the latitude and longitude of the class
//                             print(
//                                 "Latitude: $classLatitude, Longitude: $classLongitude");

//                             // Check if current date and time is within specified range and route user
//                             if (now.isAfter(DateTime.parse(value
//                                     .upcomingClasses[index]["start_time"])) &&
//                                 now.isBefore(DateTime.parse(value
//                                     .upcomingClasses[index]["end_time"]))) {
//                               // Check location of student
//                               if (await isWithinLocationRadius(
//                                   classLatitude, classLongitude)) {
//                                 QuickAlert.show(
//                                   context: context,
//                                   type: QuickAlertType.confirm,
//                                   title: "Attendance",
//                                   text:
//                                       "Mark attendance for ${value.upcomingClasses[index]["course_title"]}",

//                                   // Navigate to mark attendance page
//                                   onConfirmBtnTap: () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => MarkAttendance(
//                                         classId: value.upcomingClasses[index]
//                                             ["_id"],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 QuickAlert.show(
//                                     context: context,
//                                     type: QuickAlertType.error,
//                                     title: "Sorry",
//                                     text:
//                                         "You are not in class and thus can't mark attendance.");
//                               }
//                             } else if (now.isBefore(DateTime.parse(
//                                 value.upcomingClasses[index]["start_time"]))) {
//                               QuickAlert.show(
//                                   context: context,
//                                   type: QuickAlertType.error,
//                                   title: "Sorry",
//                                   text: "The class has not started yet.");
//                             } else if (now.isAfter(DateTime.parse(
//                                 value.upcomingClasses[index]["end_time"]))) {
//                               QuickAlert.show(
//                                   context: context,
//                                   type: QuickAlertType.error,
//                                   title: "Sorry",
//                                   text:
//                                       "The time has passed and you missed the class.");
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 15, vertical: 5),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                   color: Colors.grey[300] ?? Colors.black),
//                             ),
//                             child: Row(
//                               children: [
//                                 const SizedBox(
//                                     height: 50,
//                                     child: VerticalDivider(
//                                         color: Colors.blue, thickness: 5)),
//                                 Expanded(
//                                     child: Column(
//                                   children: [
//                                     Text(value.upcomingClasses[index]
//                                         ["class_name"]),
//                                     Text(value.upcomingClasses[index]
//                                         ["course_title"]),
//                                     Text(
//                                       "Start: ${DateFormat('HH:mm     dd/MM/yyyy').format(DateTime.parse(value.upcomingClasses[index]["start_time"]))}",
//                                     ),
//                                     Text(
//                                       "End: ${DateFormat('HH:mm     dd/MM/yyyy').format(DateTime.parse(value.upcomingClasses[index]["end_time"]))}",
//                                     ),
//                                   ],
//                                 )),
//                                 Image.asset(
//                                   "assets/images/facial-recognition-icon.png",
//                                   height: 40,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//                     );
//                   },
//                 );
//               }
//             },
//           ),
//         )
//       ],
//     ),
//   );
// }
