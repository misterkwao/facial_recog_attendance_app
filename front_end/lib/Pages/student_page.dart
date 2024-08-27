// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import 'package:student_attendance_app/Providers/students_page_provider.dart';
import 'package:student_attendance_app/Student/upload_face.dart';

import '../Constants/student_constants.dart';
import '../Constants/student_drawer.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _internetSubscription;

  bool hasInternet = true;

  // Check if location permission is granted
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: "Oops",
          text: "Location services are disabled");
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Permission Denied",
          text:
              "Please enable location services and grant necessary permissions.",
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Permission Denied Forever",
        text:
            "Please enable location services and grant necessary permissions.",
      );
    }
  }

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  void initState() {
    super.initState();

    _internetSubscription = InternetConnectionChecker().onStatusChange.listen(
      (status) {
        final hasInternet = status == InternetConnectionStatus.connected;
        setState(() {
          this.hasInternet = hasInternet;
        });

        if (this.hasInternet) {
          //Reload page when connectivity is restored
          Provider.of<StudentsPageProvider>(context, listen: false)
              .fetchDetails(context);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check location permission only when the app starts up
      await _checkLocationPermission();
      await Provider.of<StudentsPageProvider>(context, listen: false)
          .fetchDetails(context);

      var list = Provider.of<StudentsPageProvider>(context, listen: false)
          .studentCourses;

      print(list);

      print("Face not enrolled");
      print(Provider.of<StudentsPageProvider>(context, listen: false)
          .studentProfile["is_face_enrolled"]);
      print(Provider.of<StudentsPageProvider>(context, listen: false)
          .studentProfile);

      if (context
              .read<StudentsPageProvider>()
              .studentProfile["is_face_enrolled"] ==
          false) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: "Urgent!",
          barrierDismissible: false,
          text:
              "Please you need to upload your face to the database to be able to mark attendance for classes.",
          onConfirmBtnTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const UploadFace(),
          )),
        );
      }
    });
  }

  @override
  void dispose() {
    _internetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Consumer<StudentsPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (context, constraints) {
          // Trigger data fetching
          if (value.studentProfile.isEmpty && value.studentCourses.isEmpty) {
            // If no data is available, initiate fetch
            value.fetchDetails(context);

            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Image.asset('assets/images/cloudloading.gif'),
              ),
            );
          }

          return FutureBuilder(
            future: _checkInternetConnection(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Image.asset('assets/images/cloudloading.gif'),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data == true) {
                // If data is available, build the screen
                if (constraints.maxWidth < 700) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    drawer: StudentDrawer(newwidth: width * 0.5),
                    body: NestedScrollView(
                      floatHeaderSlivers: true,
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            backgroundColor: Colors.white,
                            snap: true,
                            floating: true,
                            forceElevated: innerBoxIsScrolled,
                          )
                        ];
                      },
                      body: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RefreshIndicator(
                          strokeWidth: 5,
                          color: Colors.black,
                          onRefresh: () async {
                            Future.delayed(const Duration(seconds: 2));
                            return await Provider.of<StudentsPageProvider>(
                                    context,
                                    listen: false)
                                .fetchDetails(context);
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                profile(width, height),
                                const SizedBox(height: 25),
                                allCourses(context),
                                const SizedBox(height: 25),
                                courses(height, width, context),
                                const SizedBox(height: 25),
                                attendances(width, 3, context),
                                const SizedBox(height: 25),
                                upcomingClasses(height, width, context),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (constraints.maxHeight < 1500) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Row(
                      children: [
                        StudentDrawer(newwidth: width * 0.3),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20)
                                .copyWith(bottom: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  profile(width, height),
                                  const SizedBox(height: 25),
                                  allCourses(context),
                                  const SizedBox(height: 25),
                                  courses(height, width, context),
                                  const SizedBox(height: 25),
                                  attendances(width, 4, context),
                                  const SizedBox(height: 25),
                                  upcomingClasses(height, width, context),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Row(
                      children: [
                        StudentDrawer(newwidth: width * 0.3),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20)
                                .copyWith(bottom: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),
                                  profile(width, height),
                                  const SizedBox(height: 25),
                                  allCourses(context),
                                  const SizedBox(height: 25),
                                  courses(height, width, context),
                                  const SizedBox(height: 25),
                                  attendances(width, 5, context),
                                  const SizedBox(height: 25),
                                  upcomingClasses(height, width, context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/Warning.gif", height: 200),
                          const Text(
                            'No internet connection. Please check your connection and try again.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
