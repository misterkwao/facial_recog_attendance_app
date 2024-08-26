// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin/lecturerfunc/lecturer_launch.dart';
import '../Admin/studentfunc/student_launch.dart';
import '../Admin/adminfunc/admin_launch.dart';
import '../Pages/login.dart';
import '../Pages/admin_page.dart';

class AdminDrawer extends StatefulWidget {
  double newwidth;
  AdminDrawer({required this.newwidth, super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

int selectedpage = 1;

class _AdminDrawerState extends State<AdminDrawer> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Drawer(
      // width: widget.newwidth,
      backgroundColor: Colors.grey[200],
      child: SingleChildScrollView(
        child: Column(
          children: [
            const DrawerHeader(
                child: Icon(
              Icons.favorite,
              color: Colors.black,
            )),
            dashList(context, 1, const AdminPage(), "D A S H B O A R D",
                Icons.dashboard_customize_rounded),
            SizedBox(height: height * 0.02),
            dashList(
                context, 2, const AdminLaunch(), "A D M I N", Icons.settings),
            SizedBox(height: height * 0.02),
            dashList(context, 3, const LecturerLaunch(), "L E C T U R E R",
                Icons.school_rounded),
            SizedBox(height: height * 0.02),
            dashList(context, 4, const StudentLaunch(), "S T U D E N T",
                Icons.person_2_rounded),
            SizedBox(
              height: height * 0.30,
            ),
            GestureDetector(
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
              child: const ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
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
