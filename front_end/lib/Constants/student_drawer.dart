// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/student_page.dart';

import '../Pages/login.dart';

class StudentDrawer extends StatefulWidget {
  double newwidth;
  StudentDrawer({required this.newwidth, super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

int selectedpage = 1;

class _StudentDrawerState extends State<StudentDrawer> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Drawer(
      backgroundColor: Colors.grey[200],
      child: SingleChildScrollView(
        child: Column(
          children: [
            const DrawerHeader(
                child: Icon(
              Icons.favorite,
              color: Colors.black,
            )),
            dashList(context, 1, const StudentPage(), "D A S H B O A R D",
                Icons.dashboard_rounded),
            SizedBox(height: height * 0.02),
            // ListTile(
            //   leading: const Icon(
            //     Icons.face_2_rounded,
            //     color: Colors.black,
            //   ),
            //   title: const Align(
            //     alignment: Alignment.topLeft,
            //     child: FittedBox(
            //       fit: BoxFit.scaleDown,
            //       child: Text(
            //         "M A R K  A T T E N D A N C E",
            //         style: TextStyle(
            //             color: Colors.black,
            //             fontWeight: FontWeight.w500,
            //             fontSize: 20),
            //       ),
            //     ),
            //   ),
            //   tileColor: selectedpage == 2
            //       ? const Color.fromRGBO(1, 99, 169, 1)
            //       : null,
            //   onTap: () {
            //     setState(() {
            //       selectedpage = 2;
            //     });
            //     Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => const MarkAttendance(),
            //     ));
            //     setState(() {
            //       selectedpage = 1;
            //     });
            //   },
            // ),
            SizedBox(height: height * 0.5),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.black,
              ),
              title: const Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "L O G O U T",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                ),
              ),
              onTap: () => QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: "Confirm",
                text: "Are you sure you want to logout?",
                onConfirmBtnTap: () async {
                  // Get shared preferences and set each to empty
                  final SharedPreferences localStorage =
                      await SharedPreferences.getInstance();

                  //Clear the shared preferences
                  localStorage.clear();

                  Future.delayed(
                    const Duration(seconds: 2),
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    ),
                  );

                  Navigator.pop(context);

                  //Show loading indicator
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.loading,
                    title: "Loading",
                    text: "Please wait...",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashList(BuildContext context, int pagenumber, page, String tilename,
      IconData icon) {
    return ListTile(
      tileColor: selectedpage == pagenumber
          ? const Color.fromRGBO(1, 99, 169, 1)
          : null,
      leading: Icon(
        icon,
        color: selectedpage == pagenumber ? Colors.white : Colors.black,
      ),
      title: Align(
        alignment: Alignment.topLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            tilename,
            style: TextStyle(
                color: selectedpage == pagenumber ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          selectedpage = pagenumber;
        });

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
            (route) => false);
      },
    );
  }
}
