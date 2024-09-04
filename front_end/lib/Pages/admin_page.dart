// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace, unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../Admin/widgets/all_classlocs.dart';
import '../Constants/admin_constants.dart';
import '../Constants/admin_drawer.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
          Provider.of<AdminPageProvider>(context, listen: false)
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
    // final double height = MediaQuery.of(context).size.height;
    return Consumer<AdminPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Trigger data fetching
          if (value.adminProfile.isEmpty &&
              value.allLecturers.isEmpty &&
              value.allStudents.isEmpty &&
              value.classLocations.isEmpty) {
            // If no data is available, initiate fetch
            value.fetchDetails(context);
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Image.asset('assets/images/cloudloading.gif'),
              ),
            );
          }

          // If data is available, build the screen
          if (constraints.maxWidth < 700) {
            return Scaffold(
              backgroundColor: Colors.white,
              drawer: AdminDrawer(newwidth: width * 0.65),
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
                      return await Provider.of<AdminPageProvider>(context,
                              listen: false)
                          .fetchDetails(context);
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          adminProfile(context),
                          const SizedBox(height: 25),
                          userTally(),
                          const SizedBox(height: 25),
                          const AllClassLocations(),
                          const SizedBox(height: 15),
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
                  AdminDrawer(newwidth: width * 0.3),
                  Expanded(
                      child: Container(
                          child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              adminProfile(context),
                              const SizedBox(height: 25),
                              userTally(),
                              const SizedBox(height: 10),
                              const AllClassLocations(),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )))
                ],
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: const Color.fromRGBO(83, 178, 246, 1),
              body: Row(
                children: [
                  AdminDrawer(newwidth: width * 0.3),
                  Expanded(
                      child: Container(
                          child: const Column(
                    children: [],
                  )))
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
          //         body: GestureDetector(
          //           onTap: () => _checkInternetConnection(),
          //           child: Center(
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 20),
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Image.asset("assets/images/Warning.gif",
          //                       height: 200),
          //                   const Text(
          //                     'No internet connection. Please check your connection and try again.',
          //                     textAlign: TextAlign.center,
          //                   ),
          //                 ],
          //               ),
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
