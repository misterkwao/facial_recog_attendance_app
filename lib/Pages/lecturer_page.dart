import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/lecturer_page_provider.dart';

import '../Constants/lecturer_constants.dart';
import '../Constants/lecturer_drawer.dart';

// import '../Auth/lecturerClient.dart';

class LecturerPage extends StatefulWidget {
  const LecturerPage({super.key});

  @override
  State<LecturerPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<LecturerPage> {
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
                            return await Provider.of<LecturerPageProvider>(
                                    context,
                                    listen: false)
                                .fetchDetails(context);
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
                        ))
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
