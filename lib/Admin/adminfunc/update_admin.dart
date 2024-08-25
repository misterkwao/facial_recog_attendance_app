// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../../Auth/base_client.dart';
import '../../Pages/login.dart';
import '../widgets/admin_widgets.dart';

class UpdateAdmin extends StatefulWidget {
  const UpdateAdmin({super.key});

  @override
  State<UpdateAdmin> createState() => _UpdateAdminState();
}

class _UpdateAdminState extends State<UpdateAdmin> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final formKey = GlobalKey<FormState>();
    final TextEditingController usernameController = TextEditingController();

    final details = {
      "username": usernameController.text,
    };

    return Column(
      children: [
        const SizedBox(height: 10),
        modalDrag(width),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please enter new username to update the admin details",
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
                const Text("Username"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: usernameController,
                  cursorColor: Colors.black,
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
                    } else if (!RegExp(r'^(?![_.])').hasMatch(value)) {
                      return "Cannot begin with _ or .";
                    } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+$')
                        .hasMatch(value)) {
                      return "Can contain only _ and . as special characters";
                    } else if (!RegExp(r'^[a-z A-Z 0-9 ._@]+(?<![._])$')
                        .hasMatch(value)) {
                      return "Cannot end with _ or .";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  Color.fromRGBO(83, 178, 246, 1)),
                            ),
                            onPressed: () async {
                              setState(() {
                                isloading = true;
                              });
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                try {
                                  var response = await DioClient().updateAdmin(
                                      "admin_auth/update", details);
                                  if (response != null) {
                                    Navigator.pop(context);

                                    setState(() {
                                      isloading = false;
                                    });

                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: "Success",
                                        text:
                                            "Admin details successfully updated.");
                                  } else {
                                    setState(() {
                                      isloading = false;
                                    });

                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: "Ooops!",
                                        text: "Failed to update admin details");
                                  }
                                } on DioException catch (e) {
                                  setState(() {
                                    isloading = false;
                                  });
                                  print(e.message);
                                }
                              }
                            },
                            child: const Text("Update"))
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
