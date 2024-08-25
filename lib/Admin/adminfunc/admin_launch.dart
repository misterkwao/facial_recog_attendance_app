import 'package:flutter/material.dart';
import 'package:student_attendance_app/Admin/adminfunc/create_admin.dart';
import 'package:student_attendance_app/Admin/adminfunc/update_admin.dart';

import '../widgets/admin_widgets.dart';
import '../../Constants/admin_drawer.dart';
import 'delete_admin.dart';

class AdminLaunch extends StatefulWidget {
  const AdminLaunch({super.key});

  @override
  State<AdminLaunch> createState() => _AdminLaunchState();
}

class _AdminLaunchState extends State<AdminLaunch> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            drawer: AdminDrawer(newwidth: width * 0.5),
            body: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  options(
                    "Create Admin",
                    Colors.black,
                    Colors.white,
                    context,
                    height,
                    width,
                    const CreateAdmin(),
                    0.6,
                  ),
                  options(
                    "Delete Admin",
                    Colors.black,
                    Colors.white,
                    context,
                    height,
                    width,
                    const DeleteAdmin(),
                    0.25,
                  ),
                  options(
                    "Update Admin Details",
                    Colors.black,
                    Colors.white,
                    context,
                    height,
                    width,
                    const UpdateAdmin(),
                    0.33,
                  ),
                ],
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
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        options(
                          "Create Admin",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const CreateAdmin(),
                          0.6,
                        ),
                        options(
                          "Delete Admin",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const DeleteAdmin(),
                          0.25,
                        ),
                        options(
                          "Update Admin Details",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const UpdateAdmin(),
                          0.33,
                        ),
                      ],
                    ),
                  ),
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
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        options(
                          "Create Admin",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const CreateAdmin(),
                          0.6,
                        ),
                        options(
                          "Delete Admin",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const DeleteAdmin(),
                          0.25,
                        ),
                        options(
                          "Update Admin Details",
                          Colors.black,
                          Colors.white,
                          context,
                          height,
                          width,
                          const UpdateAdmin(),
                          0.33,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
