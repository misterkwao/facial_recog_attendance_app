// ignore: file_names
// ignore_for_file: avoid_print, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Lecturer/delete_upcoming_class.dart';
import '../Providers/lecturer_page_provider.dart';
import '../Admin/widgets/admin_widgets.dart';
import '../Lecturer/create_class.dart';

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
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
                      Text("Lecturer")
                    ]),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(
                        Icons.book_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(value.lecturerProfile["lecturer_college"])
                    ]),
                    const SizedBox(height: 15),
                    Row(children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Text(value.lecturerProfile["lecturer_department"])
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
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
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
                      border:
                          Border.all(color: Colors.grey[300] ?? Colors.black)),
                  child: Row(
                    children: [
                      const SizedBox(
                          height: 50,
                          child: VerticalDivider(
                              color: Colors.blue, thickness: 5)),
                      Expanded(
                        child: Column(
                          children: [
                            Text(value.lecturerCourses[index]["course_title"]),
                            Text(
                                "Level: ${(value.lecturerCourses[index]["level"]).toString()}"),
                            Text(
                                "Semester: ${(value.lecturerCourses[index]["semester"]).toString()}")
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
        ],
      ),
    ),
  );
}

Widget lecturerGauge(double width, String week, double firstattend,
    double secondattend, double thirdattend) {
  return Container(
    width: width,
    // margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
    decoration: BoxDecoration(
        color: Colors.black, borderRadius: BorderRadius.circular(20)),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Text(
            week,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            "Intro to JAVA",
            style: TextStyle(color: Colors.white),
          ),
          lecturerCourseAttendance(firstattend),
          const SizedBox(height: 20),
          const Text(
            "Computer Networks",
            style: TextStyle(color: Colors.white),
          ),
          lecturerCourseAttendance(secondattend),
          const SizedBox(height: 20),
          const Text(
            "E-commerce",
            style: TextStyle(color: Colors.white),
          ),
          lecturerCourseAttendance(thirdattend)
        ],
      ),
    ),
  );
}

Widget lecturerCourseAttendance(double attendance) {
  return SfLinearGauge(
    animateAxis: true,
    animateRange: true,
    animationDuration: 5000,
    axisLabelStyle: const TextStyle(color: Colors.white),
    minimum: 0,
    maximum: 500,
    barPointers: [
      LinearBarPointer(
        value: attendance,
        color: Colors.blueAccent,
      )
    ],
  );
}

Widget carousel(double width) {
  return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 30),
        enlargeCenterPage: true,
        viewportFraction: 1,
        aspectRatio: 16 / 9,
      ),
      items: [
        lecturerGauge(width, "Week 5", 146, 367, 437),
        lecturerGauge(width, "Week 6", 457, 287, 239),
        lecturerGauge(width, "Week 7", 361, 203, 424),
      ]);
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
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Name",
              style: TextStyle(color: Colors.white),
            ),
            // Text(
            //   "Email",
            //   style: TextStyle(color: Colors.white),
            // ),
            Text(
              "College",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
        MediaQuery.removePadding(
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
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        MediaQuery.removePadding(
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
                                      Row(
                                        children: [
                                          const Icon(Icons.stop_circle_rounded),
                                          const SizedBox(width: 10),
                                          Text(
                                            value.lecturerUpcomingClasses[index]
                                                ["course_title"],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                      const Text(
                                        "Location:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        value.lecturerUpcomingClasses[index]
                                            ["class_name"],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Start:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('HH:mm     dd/MM/yyyy')
                                            .format(DateTime.parse(
                                                value.lecturerUpcomingClasses[
                                                    index]["start_time"])),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "End:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('HH:mm     dd/MM/yyyy')
                                            .format(DateTime.parse(
                                                value.lecturerUpcomingClasses[
                                                    index]["end_time"])),
                                      ),
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
                                onTap: () {
                                  selectedUpcomingClass = index;
                                  modalSheet(context, 0.4, width, height,
                                      const DeleteUpcomingClass());
                                },
                                child: const Text(
                                  "Delete class",
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
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
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Color.fromRGBO(83, 178, 246, 1))),
                onPressed: () {
                  modalSheet(context, 0.7, width, height, const CreateClass());
                },
                child: const Text(
                  "Create class",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.black),
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    DateFormat("d MMMM, yyyy").format(
                                      DateTime.parse(
                                          flattenedList[index]["start_time"]),
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  "Course title: ${flattenedList[index]["course_title"]}"),
                              Text(
                                  "Level taught: ${(flattenedList[index]["course_level"]).toString()}"),
                              Text(
                                  "Expected attendances: ${(flattenedList[index]["expected_no_attendees"]).toString()}"),
                              Text(
                                  "No of attendances: ${(flattenedList[index]["no_of_attendees"]).toString()}"),
                              Text(
                                  "Performance: ${(flattenedList[index]["performance"]).toString()}")
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
                  : pw.ListView.builder(
                      itemCount:
                          flattenedList[mainIndex]["attendee_names"].length,
                      itemBuilder: (context, index) {
                        return pw.Text(
                            "${(index + 1).toString()}. ${flattenedList[mainIndex]["attendee_names"][index]}");
                      },
                    ),
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Attendee Names",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Color.fromRGBO(83, 178, 246, 1))),
                onPressed: () async {
                  await saveAsPDF(context);
                },
                child: const Text(
                  "Download as PDF",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              flattenedList[mainIndex]["course_title"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat("d MMMM, yyyy").format(
                DateTime.parse(flattenedList[mainIndex]["start_time"]),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                    style: const TextStyle(fontSize: 16),
                  );
                }),
      ],
    ),
  );
}
