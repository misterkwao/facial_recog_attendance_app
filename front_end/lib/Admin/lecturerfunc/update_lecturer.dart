import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../widgets/admin_widgets.dart';
import '../widgets/lecturer_widgets.dart';
import 'create_lecturer.dart';

class UpdateLecturer extends StatefulWidget {
  const UpdateLecturer({super.key});

  @override
  State<UpdateLecturer> createState() => _UpdateLecturerState();
}

final formKey = GlobalKey<FormState>();

class _UpdateLecturerState extends State<UpdateLecturer> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

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
                  const Text("Lecturer id"),
                  const SizedBox(height: 10),
                  TextFormField(
                    enabled: false,
                    initialValue: value.allLecturers[selectedIndex]["_id"],
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
                  const Text("Allowed courses"),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => courses[index],
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: courses.length),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // courses.add(const CoursesWidget());
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: const Icon(Icons.add),
                              ),
                            ),
                            const SizedBox(width: 20),
                            if (courses.length > 1)
                              InkWell(
                                onTap: () {
                                  if (courses.length > 1) {
                                    setState(() {
                                      courses.removeLast();
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                  child: const Icon(Icons.remove),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                        child: const Text("Update Lecturer"),
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
}
