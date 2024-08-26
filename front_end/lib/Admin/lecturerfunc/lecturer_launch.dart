import 'package:flutter/material.dart';

import '../../Constants/admin_drawer.dart';
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
            floatingActionButton: ElevatedButton(
              onPressed: () {
                modalSheet(context, 0.7, width, height, const Createlecturer());
              },
              style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(83, 178, 246, 1))),
              child: const Text(
                "Create Lecturer",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                modalSheet(context, 0.7, width, height, const Createlecturer());
              },
              style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(83, 178, 246, 1))),
              child: const Text(
                "Create Lecturer",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      },
    );
  }
}
