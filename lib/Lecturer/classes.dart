import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Constants/lecturer_constants.dart';

import '../Admin/lecturerfunc/delete_lecturer.dart';
import '../Admin/widgets/admin_widgets.dart';
import '../Admin/lecturerfunc/create_lecturer.dart';
import '../Constants/lecturer_drawer.dart';
import '../Lecturer/create_class.dart';
import '../Lecturer/widgets.dart';
import '../Providers/lecturer_page_provider.dart';

// import '../Auth/lecturerClient.dart';

class LectureClasses extends StatefulWidget {
  const LectureClasses({super.key});

  @override
  State<LectureClasses> createState() => _LectureClassesState();
}

class _LectureClassesState extends State<LectureClasses> {
  final ScrollController _scrollController = ScrollController();

  late StreamSubscription _internetSubscription;

  bool hasInternet = true;

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
          Provider.of<LecturerPageProvider>(context, listen: false)
              .fetchDetails(context);
        }
      },
    );
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
    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (context, constraints) {
          // Trigger data fetching
          if (value.lecturerProfile.isEmpty &&
              value.lecturerClassLocations.isEmpty &&
              value.lecturerCourses.isEmpty) {
            // && value.lecturerUpcomingClasses.isEmpty) {
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
                if (constraints.maxWidth < 700) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                    ),
                    backgroundColor: Colors.white,
                    drawer: const LecturerDrawer(),
                    body: lecClassStatistics(width, height),
                  );
                } else if (constraints.maxWidth < 1500) {
                  return Scaffold(
                      backgroundColor: Colors.white,
                      body: Row(
                        children: [
                          const LecturerDrawer(),
                          Expanded(
                            child: Container(
                                alignment: Alignment.topCenter,
                                child: lecClassStatistics(width, height)),
                          ),
                        ],
                      ));
                } else {
                  return Scaffold(
                      backgroundColor: Colors.white,
                      body: Row(
                        children: [
                          const LecturerDrawer(),
                          Expanded(
                            child: lecClassStatistics(width, height),
                          ),
                        ],
                      ));
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
