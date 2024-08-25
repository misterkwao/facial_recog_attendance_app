// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import 'admin_widgets.dart';

class CreateClassLoc extends StatefulWidget {
  const CreateClassLoc({super.key});

  @override
  State<CreateClassLoc> createState() => _CreateClassLocState();
}

final TextEditingController classname = TextEditingController();
final TextEditingController location = TextEditingController();
final TextEditingController longitude = TextEditingController();
final TextEditingController latitude = TextEditingController();

final formKey = GlobalKey<FormState>();

bool iscreateclassloading = false;

class _CreateClassLocState extends State<CreateClassLoc> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Enter details to create class location",
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
                const Text("Class name"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: classname,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.abc_rounded)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a class name";
                      // } else if (!RegExp(r'^(?![_.])').hasMatch(value)) {
                      //   return "Cannot begin with _ or .";
                      // } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+$').hasMatch(value)) {
                      //   return "Can contain only _ and . as special characters";
                      // } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+(?<![._])$')
                      //     .hasMatch(value)) {
                      //   return "Cannot end with _ or .";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text("College location"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: location,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.abc_rounded)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a college location";
                      // } else if (!RegExp(r'^(?![_.])').hasMatch(value)) {
                      //   return "Cannot begin with _ or .";
                      // } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+$').hasMatch(value)) {
                      //   return "Can contain only _ and . as special characters";
                      // } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+(?<![._])$')
                      //     .hasMatch(value)) {
                      //   return "Cannot end with _ or .";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text("Longitude"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: longitude,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.numbers_rounded)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a longitude";
                      // } else if (!RegExp(r'^(?=.{6,}$)').hasMatch(value)) {
                      //   return "Cannot be less than 6 characters";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text("Latitude"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: latitude,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.numbers_rounded)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a latitude";
                      // } else if (!RegExp(r'^(?=.{6,}$)').hasMatch(value)) {
                      //   return "Cannot be less than 6 characters";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.redAccent,
                            )),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      iscreateclassloading
                          ? const CircularProgressIndicator(
                              color: Color.fromRGBO(83, 178, 246, 1),
                            )
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

                                  setState(() {
                                    iscreateclassloading = true;
                                  });

                                  final String name = classname.text;
                                  final String collegeloc = location.text;
                                  final double longitudeloc =
                                      double.parse(longitude.text);
                                  final double latitudeloc =
                                      double.parse(latitude.text);

                                  Map<String, dynamic> classLocationDetails = {
                                    'class_name': name,
                                    'college_location': collegeloc,
                                    'location': {
                                      'longitude': longitudeloc,
                                      'latitude': latitudeloc,
                                    }
                                  };

                                  try {
                                    await context
                                        .read<AdminPageProvider>()
                                        .createClassLocation(
                                            classLocationDetails, context);

                                    setState(() {
                                      iscreateclassloading = false;
                                    });

                                    //Clear controllers
                                    classname.clear();
                                    location.clear();
                                    latitude.clear();
                                    longitude.clear();
                                  } on DioException catch (e) {
                                    setState(() {
                                      iscreateclassloading = false;
                                    });

                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: "Error",
                                        text: e.message);
                                  }
                                }
                              },
                              child: const Text("Create class location"),
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
