import 'package:flutter/material.dart';

import '../../Admin/studentfunc/create_student.dart';
import '../../Admin/widgets/student_widgets.dart';
import '../../Constants/admin_drawer.dart';
import '../widgets/admin_widgets.dart';

class StudentLaunch extends StatefulWidget {
  const StudentLaunch({super.key});

  @override
  State<StudentLaunch> createState() => _StudentLaunchState();
}

final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class _StudentLaunchState extends State<StudentLaunch> {
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
                modalSheet(context, 0.7, width, height, const CreateStudent());
              },
              style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(83, 178, 246, 1))),
              child: const Text(
                "Create Student",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: studentList(height, width, context),
          );
        } else if (constraints.maxWidth < 1500) {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: ElevatedButton(
              onPressed: () {
                print("Student courses: ${studentCourses.length}");
                modalSheet(context, 0.7, width, height, const CreateStudent());
              },
              style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(83, 178, 246, 1))),
              child: const Text(
                "Create Student",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: Row(
              children: [
                AdminDrawer(newwidth: width * 0.3),
                Expanded(
                    child: Container(
                  alignment: Alignment.center,
                  child: studentList(height, width, context),
                ))
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
