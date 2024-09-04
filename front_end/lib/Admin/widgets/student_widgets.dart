// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Admin/studentfunc/update_student.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Admin/studentfunc/delete_student.dart';
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
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  fontFamily: 'Montserrat'),
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
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
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
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Row(
                            children: [
                              Text(
                                (students[index]["student_current_level"])
                                    .toString(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              PopupMenuButton(
                                color: Colors.white,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () {
                                      selectedStudentIndex = index;
                                      modalSheet(context, 0.75, width, height,
                                          const UpdateStudent());
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
