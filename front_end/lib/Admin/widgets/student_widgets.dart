// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Admin/studentfunc/delete_student.dart';
import '../studentfunc/create_student.dart';
import 'admin_widgets.dart';

Widget textfield(IconData icon, TextEditingController controller) {
  return TextFormField(
    controller: controller,
    cursorColor: Colors.black,
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[300],
      suffixIcon: Icon(icon),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return "Field cannot be empty";
      }
      return null;
    },
  );
}

final formKey = GlobalKey<FormState>();

int selectedStudentIndex = 0;

Widget updateStudent(BuildContext context, double width) {
  return Column(
    children: [
      const SizedBox(height: 10),
      modalDrag(width),
      const SizedBox(height: 20),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Please provide details to update lecturer details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Consumer<AdminPageProvider>(
          builder: (context, value, child) => Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student id"),
                const SizedBox(height: 10),
                TextFormField(
                  enabled: false,
                  initialValue: value.allStudents[selectedStudentIndex]["_id"],
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[300],
                    suffixIcon: const Icon(Icons.numbers_rounded),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text("Year enrolled"),
                const SizedBox(height: 10),
                textfield(Icons.numbers_rounded, studentYearEnrolled),
                const SizedBox(height: 20),
                const Text("Current Level"),
                const SizedBox(height: 10),
                textfield(Icons.numbers_rounded, studentCurrentLevel),
                const SizedBox(height: 20),
                const Text("Student name"),
                const SizedBox(height: 10),
                textfield(Icons.abc, studentName),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.redAccent),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromRGBO(83, 178, 246, 1)),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                        }
                      },
                      child: const Text("Update Student"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget studentList(double height, double width, BuildContext context) {
  return Container(
    width: width,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: RefreshIndicator(
      strokeWidth: 5,
      color: Colors.black,
      onRefresh: () async {
        Future.delayed(const Duration(seconds: 2));
        return await Provider.of<AdminPageProvider>(context, listen: false)
            .fetchDetails(context);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student List",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Consumer<AdminPageProvider>(
                builder: (context, value, child) {
                  var students = value.allStudents;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.allStudents.length,
                    itemBuilder: (context, index) => Container(
                      width: width,
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey[300] ?? Colors.black)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                  color: Colors.blue, thickness: 5)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              child: Text(
                                students[index]["student_name"],
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              child: Text(
                                students[index]["student_department"],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                (students[index]["student_current_level"])
                                    .toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                              PopupMenuButton(
                                color: Colors.white,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () {
                                      selectedStudentIndex = index;
                                      modalSheet(context, 0.4, width, height,
                                          updateStudent(context, width));
                                    },
                                    child: const Text(
                                      "Update details",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      selectedStudentIndex = index;
                                      modalSheet(context, 0.4, width, height,
                                          const DeleteStudent());
                                    },
                                    child: const Text(
                                      "Delete student",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // adminAccountList(),
          ],
        ),
      ),
    ),
  );
}
