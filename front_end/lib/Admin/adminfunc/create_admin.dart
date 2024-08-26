// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:student_attendance_app/Pages/login.dart';

import '../../Auth/base_client.dart';
import '../widgets/admin_widgets.dart';

class CreateAdmin extends StatefulWidget {
  const CreateAdmin({super.key});

  @override
  State<CreateAdmin> createState() => _CreateAdminState();
}

class _CreateAdminState extends State<CreateAdmin> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final formKey = GlobalKey<FormState>();

    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String name;
    String email;
    String password;

    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Text(
          "Fill in details to create an admin",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Username"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.person)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a username";
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
                const Text("Email"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.email_rounded)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter an email address";
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
                const Text("Password"),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[300],
                      suffixIcon: const Icon(Icons.password)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter a password";
                      // } else if (!RegExp(r'^(?=.{6,}$)').hasMatch(value)) {
                      //   return "Cannot be less than 6 characters";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.redAccent,
                          )),
                      onPressed: () => Navigator.pop(context),
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
                                  Color.fromRGBO(83, 178, 246, 1),
                                )),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                setState(() {
                                  isloading = true;
                                });

                                name = usernameController.text;
                                email = emailController.text;
                                password = passwordController.text;

                                final details = {
                                  'username': name,
                                  'email': email,
                                  'password': password
                                };

                                const CircularProgressIndicator(
                                  color: Colors.black,
                                );

                                // print(details);

                                // print(jsonDecode(details).runtimeType);

                                var response = await DioClient()
                                    .postCreateAdmin("admin_auth/signup",
                                        json.encode(details));

                                // print(response);
                                if (response != null) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.success,
                                      title: "Success",
                                      text: "Admin created successfully");
                                  setState(() {
                                    isloading = false;
                                  });
                                } else {
                                  setState(() {
                                    isloading = false;
                                  });
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: "Ooops!",
                                      text: "Failed to create admin");
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              "Create",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
