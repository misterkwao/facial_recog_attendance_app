// ignore: file_names
// ignore_for_file: avoid_print, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:quickalert/quickalert.dart';

import '../Lecturer/delete_upcoming_class.dart';
import '../Providers/lecturer_page_provider.dart';
import '../Admin/widgets/admin_widgets.dart';
import '../Lecturer/create_class.dart';
import '../Student/mark_attendance.dart';

Widget lecturerProfile(double width, double height) {
  return Container(
    width: width,
    child: Consumer<LecturerPageProvider>(
      builder: (context, value, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, ${value.lecturerProfile["lecturer_name"]}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 25,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 20),
          JelloIn(
            duration: Duration(milliseconds: 1500),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300] ?? Colors.black),
              ),
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: LottieBuilder.asset(
                      "assets/images/lecturer.json",
                      height: 100,
                    ),
                  ),
                  Column(
                    children: [
                      const Row(children: [
                        Icon(
                          Icons.person_3_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Lecturer",
                            style: TextStyle(
                                fontFamily: 'Montserrat', fontSize: 15),
                          ),
                        )
                      ]),
                      const SizedBox(height: 15),
                      Row(children: [
                        const Icon(
                          Icons.book_outlined,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            value.lecturerProfile["lecturer_college"],
                            style: TextStyle(
                                fontFamily: 'Montserrat', fontSize: 15),
                          ),
                        )
                      ]),
                      const SizedBox(height: 15),
                      Row(children: [
                        const Icon(
                          Icons.school_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            value.lecturerProfile["lecturer_department"],
                            style: TextStyle(
                                fontFamily: 'Montserrat', fontSize: 15),
                          ),
                        )
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget lecturerCourses(double height, double width, BuildContext context) {
  return Container(
    width: width,
    child: Consumer<LecturerPageProvider>(
      builder: (context, value, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Courses Taught",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 10),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: SlideInLeft(
              duration: Duration(milliseconds: 1500),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: value.lecturerCourses.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.grey[300] ?? Colors.black)),
                    child: Row(
                      children: [
                        const SizedBox(
                            height: 50,
                            child: VerticalDivider(
                                color: Colors.blue, thickness: 5)),
                        Expanded(
                          child: Column(
                            children: [
                              Text(value.lecturerCourses[index]["course_title"],
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 15)),
                              Text(
                                  "Level: ${(value.lecturerCourses[index]["level"]).toString()}",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 15)),
                              Text(
                                  "Semester: ${(value.lecturerCourses[index]["semester"]).toString()}",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 15))
                            ],
                          ),
                        ),
                        const Icon(Icons.bookmark_outline,
                            color: Colors.blue, size: 20)
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget lecClassLocations(double width, BuildContext context) {
  return Container(
    width: width,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.black,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Class Location List",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Name",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Colors.white)),
            // Text(
            //   "Email",
            //   style: TextStyle(color: Colors.white),
            // ),
            Text("College",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Colors.white))
          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
        SlideInLeft(
          duration: Duration(milliseconds: 1500),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Consumer<LecturerPageProvider>(
              builder: (context, value, child) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.lecturerClassLocations.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value.lecturerClassLocations[index]["class_name"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Kanit",
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        value.lecturerClassLocations[index]["college_location"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

int selectedUpcomingClass = 0;

Widget lecUpcomingClasses(BuildContext context, double width, double height) {
  return Container(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming classes",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 10),
        SlideInRight(
          duration: Duration(milliseconds: 1500),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Consumer<LecturerPageProvider>(
              builder: (context, value, child) {
                if (value.lecturerUpcomingClasses[0] == "No classes" ||
                    value.lecturerUpcomingClasses[0] == "no classes") {
                  return Container(
                    width: width,
                    child: const Center(
                      child: Text(
                        "No upcoming classes available",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.lecturerUpcomingClasses.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: width,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.grey[300] ?? Colors.black),
                                ),
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.stop_circle_rounded),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                    value.lecturerUpcomingClasses[
                                                        index]["course_title"],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 15)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          (value.lecturerUpcomingClasses[index]
                                                  ["course_level"])
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Kanit",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: const Text("Location:",
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat-Bold',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(
                                            value.lecturerUpcomingClasses[index]
                                                ["class_name"],
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: const Text("Start:",
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat-Bold',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(
                                            DateFormat('HH:mm     dd/MM/yyyy')
                                                .format(DateTime.parse(value
                                                        .lecturerUpcomingClasses[
                                                    index]["start_time"])),
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: const Text("End:",
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat-Bold',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(
                                            DateFormat('HH:mm     dd/MM/yyyy')
                                                .format(DateTime.parse(value
                                                        .lecturerUpcomingClasses[
                                                    index]["end_time"])),
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              color: Colors.white,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () async {
                                    // Get current date and time
                                    DateTime now = DateTime.now();

                                    // Function to check if student is within a 10 meter radius of the location
                                    Future<bool> isWithinLocationRadius(
                                        double latitude,
                                        double longitude) async {
                                      Position position =
                                          await Geolocator.getCurrentPosition(
                                              desiredAccuracy:
                                                  LocationAccuracy.high);

                                      print(position);

                                      double distance =
                                          Geolocator.distanceBetween(
                                        position.latitude,
                                        position.longitude,
                                        latitude,
                                        longitude,
                                      );

                                      // Print the distance between the
                                      print(distance);

                                      return distance <= 10.0;
                                    }

                                    // Get the longitude and latitude where class is being held
                                    final double classLatitude =
                                        value.lecturerUpcomingClasses[index]
                                            ["location"]["latitude"];
                                    final double classLongitude =
                                        value.lecturerUpcomingClasses[index]
                                            ["location"]["longitude"];

                                    // Check if current date and time is within specified range and route user
                                    if (now.isAfter(DateTime.parse(value.lecturerUpcomingClasses[index]["start_time"])) &&
                                        now.isBefore(DateTime.parse(
                                            value.lecturerUpcomingClasses[index]
                                                ["end_time"]))) {
                                      // Show bottom sheet to let user know you are checking location
                                      showModalBottomSheet(
                                        barrierColor: Colors.black26,
                                        backgroundColor: Colors.white,
                                        // showDragHandle: true,
                                        sheetAnimationStyle: AnimationStyle(
                                            curve: Curves.easeIn),
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
                                                      "assets/images/map.gif"),
                                                  const Text(
                                                      "Making sure you are in class")
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
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
                                              "Mark attendance for ${value.lecturerUpcomingClasses[index]["course_title"]}",

                                          // Navigate to mark attendance page
                                          onConfirmBtnTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MarkAttendance(
                                                classId: value
                                                        .lecturerUpcomingClasses[
                                                    index]["_id"],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Pop modal bottom sheet

                                        Navigator.pop(context);

                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            title: "Sorry",
                                            text:
                                                "You are not in class and thus can't mark attendance.");
                                      }
                                    } else if (now.isBefore(DateTime.parse(
                                        value.lecturerUpcomingClasses[index]
                                            ["start_time"]))) {
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: "Sorry",
                                          text:
                                              "The class has not started yet.");
                                    } else if (now.isAfter(DateTime.parse(
                                        value.lecturerUpcomingClasses[index]
                                            ["end_time"]))) {
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: "Sorry",
                                          text:
                                              "The time has passed and you missed the class.");
                                    }
                                  },
                                  child: const Text("Mark Attendance"),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    selectedUpcomingClass = index;
                                    modalSheet(context, 0.4, width, height,
                                        const DeleteUpcomingClass());
                                  },
                                  child: const Text(
                                    "Delete class",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                              child: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
                onPressed: () {
                  print(context.read<LecturerPageProvider>().lecturerCourses);
                  modalSheet(context, 0.7, width, height, const CreateClass());
                },
                child: const Text(
                  "Create class",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat Bold'),
                )),
          ],
        ),
      ],
    ),
  );
}

Widget lecClassStatistics(double width, double height) {
  DateTime now = DateTime.now();
  int currentYear = now.year;
  int currentMonth = now.month;
  String currentMonthInWords =
      "Class Statistics for ${DateFormat('MMMM').format(now)}";

  List<dynamic> filteredClassStatistics = [];
  List<dynamic> flattenedList = [];

  return Consumer<LecturerPageProvider>(builder: (context, value, child) {
    for (var yearData in value.lecturerClassStatistics) {
      if (yearData["_id"]["year"] == currentYear) {
        for (var monthData in yearData["months"]) {
          if (monthData["month"] == currentMonth) {
            for (var weekData in monthData["weeks"]) {
              filteredClassStatistics.add(weekData["classes"]);
            }
          }
        }
      }
    }

    for (var sublist in filteredClassStatistics) {
      flattenedList.addAll(sublist);
    }

    print("Filtered classes: $filteredClassStatistics");

    print("Flattened classes: $flattenedList");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RefreshIndicator(
        strokeWidth: 5,
        color: Colors.black,
        onRefresh: () async {
          Future.delayed(const Duration(seconds: 2));
          return await Provider.of<LecturerPageProvider>(context, listen: false)
              .fetchDetails(context);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentMonthInWords,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: flattenedList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => modalSheet(
                      context,
                      0.7,
                      width,
                      height,
                      attendeeNames(width, index, flattenedList, context),
                    ),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.grey[300] ?? Colors.black),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const SizedBox(
                              height: 100,
                              child: VerticalDivider(
                                  color: Colors.blue, thickness: 5)),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      flattenedList[index]["class_name"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                  Text(
                                    DateFormat("d MMMM, yyyy").format(
                                      DateTime.parse(
                                          flattenedList[index]["start_time"]),
                                    ),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Course title: ${flattenedList[index]["course_title"]}",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 15),
                              ),
                              Text(
                                "Level taught: ${(flattenedList[index]["course_level"]).toString()}",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 15),
                              ),
                              Text(
                                "Expected attendances: ${(flattenedList[index]["expected_no_attendees"]).toString()}",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 15),
                              ),
                              Text(
                                "No of attendances: ${(flattenedList[index]["no_of_attendees"]).toString()}",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 15),
                              ),
                              Text(
                                "Performance: ${(flattenedList[index]["performance"]).toString()}",
                                style: TextStyle(
                                    fontFamily: 'Montserrat', fontSize: 15),
                              )
                            ],
                          ))
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  });
}

Widget attendeeNames(
    double width, int mainIndex, List flattenedList, BuildContext context) {
  String classDate = DateFormat("d MMMM, yyyy")
      .format(DateTime.parse(flattenedList[mainIndex]["start_time"]));

  // Function to save as pdf file
  Future<void> saveAsPDF(BuildContext context) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${flattenedList[mainIndex]["course_title"]}',
                style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline),
              ),
              pw.Text(
                "Attendees for class held on $classDate",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              (flattenedList[mainIndex]["attendee_names"]).isEmpty
                  ? pw.Text("No student attended the class")
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: List.generate(
                        flattenedList[mainIndex]["attendee_names"].length,
                        (index) {
                          return pw.Padding(
                            padding: pw.EdgeInsets.only(bottom: 10),
                            child: pw.Text(
                              "${(index + 1).toString()}. ${flattenedList[mainIndex]["attendee_names"][index]}",
                              style: pw.TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ))
              // pw.ListView.builder(
              //     itemCount:
              //         flattenedList[mainIndex]["attendee_names"].length,
              //     itemBuilder: (context, index) {
              //       return pw.Text(
              //           "${(index + 1).toString()}. ${flattenedList[mainIndex]["attendee_names"][index]}",
              //           style: pw.TextStyle(fontSize: 16));
              //     },
              //   ),
            ],
          );
        },
      ),
    );
    // Get platfrom specific directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    String path =
        "${directory?.path}/${flattenedList[mainIndex]["course_title"]}-attendees.pdf";

    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Open tehe PDF file
    await OpenFile.open(path);

    // Show a alert or dialog to confirm the PDF has been saved
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Saved",
      text: Platform.isAndroid
          ? "PDF saved to Downloads"
          : "PDF saved to Documents",
    );
  }

  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
                onPressed: () async {
                  await saveAsPDF(context);
                },
                child: const Text(
                  "Download as PDF",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat Bold'),
                )),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Attendee Names",
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 25,
              fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                flattenedList[mainIndex]["course_title"],
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Montserrat'),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat("d MMMM, yyyy").format(
                DateTime.parse(flattenedList[mainIndex]["start_time"]),
              ),
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Montserrat'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        flattenedList[mainIndex]["attendee_names"].isEmpty
            ? Container(
                width: width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300] ?? Colors.black),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: const Text("No student attended the class."),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (flattenedList[mainIndex]["attendee_names"]).length,
                itemBuilder: (context, index) {
                  return Text(
                    "${(index + 1).toString()}. ${flattenedList[mainIndex]["attendee_names"][index]}",
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                  );
                }),
      ],
    ),
  );
}

final List<Map<String, dynamic>> data = [
  {
    "year": 2024,
    "months": [
      {
        "month": 8,
        "weeks": [
          {
            "week": 34,
            "classes": [
              {
                "class_name": "Introduction to Compilers",
                "start_time": "2024-08-20T09:33:00",
                "performance": 0.0,
              },
              {
                "class_name": "Introduction to Compilers",
                "start_time": "2024-08-21T08:30:00",
                "performance": 50.0,
              },
            ],
          },
          {
            "week": 35,
            "classes": [
              {
                "class_name": "Introduction to Compilers",
                "start_time": "2024-08-27T17:36:00",
                "performance": 50.0,
              },
            ],
          }
        ],
      },
    ],
  },
];

class ClassData {
  final String name;
  final DateTime date;
  final double performance;

  ClassData(this.date, this.performance, this.name);
}
