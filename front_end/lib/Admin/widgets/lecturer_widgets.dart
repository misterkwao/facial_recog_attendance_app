import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Admin/lecturerfunc/delete_lecturer.dart';
import '../../Admin/lecturerfunc/update_lecturer.dart';
import 'admin_widgets.dart';

Widget textfield(IconData icon) {
  return TextFormField(
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

int selectedIndex = 0;

Widget lecturerList(double height, double width, BuildContext newcontext) {
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: RefreshIndicator(
      strokeWidth: 5,
      color: Colors.black,
      onRefresh: () async {
        Future.delayed(const Duration(seconds: 2));
        return await Provider.of<AdminPageProvider>(newcontext, listen: false)
            .fetchDetails(newcontext);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lecturer List",
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            MediaQuery.removePadding(
              context: newcontext,
              removeTop: true,
              removeBottom: true,
              child: Consumer<AdminPageProvider>(
                builder: (context, value, child) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: value.allLecturers.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.grey[300] ?? Colors.black)),
                    child: Row(
                      children: [
                        const SizedBox(
                            height: 40,
                            child: VerticalDivider(
                                color: Colors.blue, thickness: 5)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              value.allLecturers[index]["lecturer_name"],
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: (value.allLecturers[index]["allowed_courses"])
                                      .length ==
                                  1
                              ? Text(
                                  "${((value.allLecturers[index]["allowed_courses"]).length).toString()} course",
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "${((value.allLecturers[index]["allowed_courses"]).length).toString()} courses",
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 15),
                        PopupMenuButton(
                          color: Colors.white,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                selectedIndex = index;
                                modalSheet(context, 0.7, width, height,
                                    const UpdateLecturer());
                              },
                              child: const Text(
                                "Update details",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                selectedIndex = index;
                                modalSheet(context, 0.4, width, height,
                                    const DeleteLecturer());
                              },
                              child: const Text(
                                "Delete lecturer",
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
                  ),
                ),
              ),
            ),

            // adminAccountList(),
          ],
        ),
      ),
    ),
  );
}
