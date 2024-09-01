import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../../Constants/admin_drawer.dart';
import '../../Providers/admin_page_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/lecturer_widgets.dart';
import 'create_lecturer.dart';

class LecturerLaunch extends StatefulWidget {
  const LecturerLaunch({super.key});

  @override
  State<LecturerLaunch> createState() => _LecturerLaunchState();
}

final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class _LecturerLaunchState extends State<LecturerLaunch> {
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
    final double height = MediaQuery.of(context).size.height;
    return Consumer<AdminPageProvider>(
      builder: (context, value, child) => LayoutBuilder(
        builder: (context, constraints) {
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
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                    ),
                    backgroundColor: Colors.white,
                    drawer: AdminDrawer(newwidth: width * 0.5),
                    floatingActionButton: ElevatedButton(
                      onPressed: () {
                        modalSheet(context, 0.7, width, height,
                            const Createlecturer());
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.blueAccent)),
                      child: const Text(
                        "Create Lecturer",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat Bold'),
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    body: lecturerList(height, width, context),
                  );
                } else if (constraints.maxWidth < 1500) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    floatingActionButton: ElevatedButton(
                      onPressed: () {
                        modalSheet(context, 0.7, width, height,
                            const Createlecturer());
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.blueAccent)),
                      child: const Text(
                        "Create Lecturer",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat Bold'),
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    body: Row(
                      children: [
                        AdminDrawer(newwidth: width * 0.3),
                        Expanded(
                          child: lecturerList(height, width, context),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Scaffold(
                    backgroundColor: const Color.fromRGBO(83, 178, 246, 1),
                    body: Row(
                      children: [
                        AdminDrawer(newwidth: width * 0.3),
                        Expanded(child: Container())
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
