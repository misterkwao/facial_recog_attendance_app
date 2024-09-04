// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Lecturer/lecturer_notifications.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

import '../Constants/lecturer_constants.dart';
import '../Constants/lecturer_drawer.dart';
import '../Student/upload_face.dart';

// import '../Auth/lecturerClient.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({super.key});

  @override
  State<LecturerPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<LecturerPage> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _internetSubscription;
  int notificationCount = 0;
  bool notify = false;

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
          Provider.of<LecturerPageProvider>(context, listen: false)
              .fetchDetails(context);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check location permission only when the app starts up
      await _checkLocationPermission();
      await Provider.of<LecturerPageProvider>(context, listen: false)
          .fetchDetails(context);

      if (context
              .read<LecturerPageProvider>()
              .lecturerProfile["is_face_enrolled"] ==
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
    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
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

          // Reset notification count
          notificationCount = 0;
          notify = false;

          List notification =
              context.read<LecturerPageProvider>().lecturerNotifications;
          // print("notifications: " + notification.toString());

          for (var i = 0; i < notification.length; i++) {
            if (notification[i]['details']['is_read'] == false) {
              notificationCount++;
              notify = true;
            }
          }

          // If data is available, build the screen
          if (constraints.maxWidth < 700) {
            return Scaffold(
              backgroundColor: Colors.white,
              // appBar: AppBar(
              //   backgroundColor: Colors.white,
              // ),
              drawer: const LecturerDrawer(),
              body: NestedScrollView(
                controller: _scrollController,
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      actions: [
                        notify
                            ? InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        LecturerNotifications(),
                                  ));
                                  selectedpage = 3;
                                },
                                child: Badge(
                                  label: Text(notificationCount.toString()),
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.notifications, size: 30),
                                ),
                              )
                            : Icon(
                                Icons.notifications,
                                size: 30,
                                color: Colors.blueAccent,
                              ),
                        SizedBox(width: 15),
                      ],
                      backgroundColor: Colors.white,
                      snap: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                    )
                  ];
                },
                body: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: RefreshIndicator(
                    strokeWidth: 5,
                    color: Colors.black,
                    onRefresh: () async {
                      Future.delayed(const Duration(seconds: 2));
                      await Provider.of<LecturerPageProvider>(context,
                              listen: false)
                          .fetchDetails(context);

                      // check if is_face_enrolled is false
                      if (Provider.of<LecturerPageProvider>(context,
                                  listen: false)
                              .lecturerProfile["is_face_enrolled"] ==
                          false) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.info,
                          title: "Urgent!",
                          barrierDismissible: false,
                          text:
                              "Please you need to upload your face to the database to be able to mark attendance for classes.",
                          onConfirmBtnTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const UploadFace(),
                          )),
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          lecturerProfile(width, height),
                          const SizedBox(height: 25),
                          lecturerCourses(height, width, context),
                          const SizedBox(height: 25),
                          lecUpcomingClasses(context, width, height),
                          const SizedBox(height: 25),
                          lecClassLocations(width, context),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (constraints.maxWidth < 1500) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  const LecturerDrawer(),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(20),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        Future.delayed(const Duration(seconds: 2));
                        await Provider.of<LecturerPageProvider>(context,
                                listen: false)
                            .fetchDetails(context);

                        // check if is_face_enrolled is false
                        if (Provider.of<LecturerPageProvider>(context,
                                    listen: false)
                                .lecturerProfile["is_face_enrolled"] ==
                            false) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.info,
                            title: "Urgent!",
                            barrierDismissible: false,
                            text:
                                "Please you need to upload your face to the database to be able to mark attendance for classes.",
                            onConfirmBtnTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const UploadFace(),
                            )),
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            lecturerProfile(width, height),
                            const SizedBox(height: 25),
                            lecturerCourses(height, width, context),
                            const SizedBox(height: 25),
                            lecUpcomingClasses(context, width, height),
                            const SizedBox(height: 25),
                            lecClassLocations(width, context),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  const LecturerDrawer(),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(20),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        Future.delayed(const Duration(seconds: 2));
                        await Provider.of<LecturerPageProvider>(context,
                                listen: false)
                            .fetchDetails(context);

                        // check if is_face_enrolled is false
                        if (Provider.of<LecturerPageProvider>(context,
                                    listen: false)
                                .lecturerProfile["is_face_enrolled"] ==
                            false) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.info,
                            title: "Urgent!",
                            barrierDismissible: false,
                            text:
                                "Please you need to upload your face to the database to be able to mark attendance for classes.",
                            onConfirmBtnTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const UploadFace(),
                            )),
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            lecturerProfile(width, height),
                            const SizedBox(height: 25),
                            lecturerCourses(height, width, context),
                            const SizedBox(height: 25),
                            lecUpcomingClasses(context, width, height),
                            const SizedBox(height: 25),
                            lecClassLocations(width, context),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            );
          }

          // return FutureBuilder(
          //   future: _checkInternetConnection(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Scaffold(
          //         backgroundColor: Colors.white,
          //         body: Center(
          //           child: Image.asset('assets/images/cloudloading.gif'),
          //         ),
          //       );
          //     } else if (snapshot.hasData && snapshot.data == true) {

          //     } else {
          //       return Scaffold(
          //         backgroundColor: Colors.white,
          //         body: Center(
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(horizontal: 20),
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Image.asset("assets/images/Warning.gif", height: 200),
          //                 const Text(
          //                   'No internet connection. Please check your connection and try again.',
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // );
        },
      ),
    );
  }
}
