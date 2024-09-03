import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Constants/lecturer_drawer.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

class LecturerNotifications extends StatefulWidget {
  const LecturerNotifications({super.key});

  @override
  State<LecturerNotifications> createState() => _LecturerNotificationsState();
}

class _LecturerNotificationsState extends State<LecturerNotifications> {
  late StreamSubscription _internetSubscription;
  final ScrollController _scrollController = ScrollController();

  bool hasInternet = true;

  // Function to check internet connectivity
  Future<bool> _checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    // _webViewController = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadRequest(Uri.parse("https://www.google.com"));

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

          // testLink = context.read<StudentsPageProvider>().studentNotifications[]
        }
      },
    );
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _internetSubscription.cancel();
    // _webViewController.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Consumer<LecturerPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (context, constraints) {
          // Trigger data fetching
          if (value.lecturerProfile.isEmpty && value.lecturerCourses.isEmpty) {
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
                    drawer: LecturerDrawer(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RefreshIndicator(
                          strokeWidth: 5,
                          color: Colors.black,
                          onRefresh: () async {
                            Future.delayed(const Duration(seconds: 2));
                            await Provider.of<LecturerPageProvider>(context,
                                    listen: false)
                                .fetchDetails(context);
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notifications",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 25,
                                      fontFamily: 'Montserrat'),
                                ),
                                const SizedBox(height: 10),
                                MediaQuery.removePadding(
                                    removeTop: true,
                                    removeBottom: true,
                                    context: context,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          value.lecturerNotifications.length,
                                      itemBuilder: (context, index) {
                                        List notification =
                                            value.lecturerNotifications;
                                        if (notification.isEmpty) {
                                          return Center(
                                            child:
                                                Text("No notifications here"),
                                          );
                                        } else {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Container(
                                              width: width,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: value.lecturerNotifications[
                                                                        index]
                                                                    ["details"]
                                                                ["is_read"] ==
                                                            false
                                                        ? Colors.blueAccent
                                                        : const Color.fromRGBO(
                                                            224, 224, 224, 1)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.blueAccent,
                                                        shape: BoxShape.circle),
                                                    child: Icon(
                                                      Icons.notifications,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            notification[index]
                                                                ["title"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Montserrat'),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            notification[index]
                                                                    ["details"]
                                                                ["description"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontFamily:
                                                                    'Montserrat'),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Icon(Icons
                                                                  .calendar_today),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text(DateFormat(
                                                                      "HH:mm   dd/MM/yyyy")
                                                                  .format(DateTime.parse(
                                                                      notification[
                                                                              index]
                                                                          [
                                                                          "createdAt"]))),
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
                                      },
                                    ))
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
                        LecturerDrawer(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20)
                                .copyWith(bottom: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Notifications",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25,
                                        fontFamily: 'Montserrat'),
                                  ),
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
                        LecturerDrawer(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20)
                                .copyWith(bottom: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Notifications",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25,
                                        fontFamily: 'Montserrat'),
                                  ),
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
