// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '/Pages/login.dart';
import 'admin_widgets.dart';
import 'all_classlocs.dart';

class DeleteClassloc extends StatefulWidget {
  const DeleteClassloc({super.key});

  @override
  State<DeleteClassloc> createState() => _DeleteClasslocState();
}

class _DeleteClasslocState extends State<DeleteClassloc> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please provide class id to delete",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Classs id"),
                const SizedBox(height: 10),
                Consumer<AdminPageProvider>(
                  builder: (context, value, child) => TextFormField(
                    enabled: false,
                    initialValue: value.classLocations[selectedClassLoc]["_id"],
                    // controller: classId,
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
                    isloading
                        ? const CircularProgressIndicator(
                            color: Color.fromRGBO(83, 178, 246, 1))
                        : ElevatedButton(
                            style: const ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromRGBO(83, 178, 246, 1)),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                              }

                              setState(() {
                                isloading = true;
                              });

                              try {
                                await context
                                    .read<AdminPageProvider>()
                                    .deleteClassLocation(context);

                                setState(() {
                                  isloading = false;
                                });
                              } on DioException catch (e) {
                                setState(() {
                                  isloading = false;
                                });
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: "Error",
                                  text: e.message,
                                );
                              }
                            },
                            child: const Text("Delete Class"),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
