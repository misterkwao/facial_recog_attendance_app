// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../../Auth/base_client.dart';
import '../../Pages/login.dart';
import '../widgets/admin_widgets.dart';

class DeleteAdmin extends StatefulWidget {
  const DeleteAdmin({super.key});

  @override
  State<DeleteAdmin> createState() => _DeleteAdminState();
}

class _DeleteAdminState extends State<DeleteAdmin> {
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
            "Are you sure you want to delete this admin?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Row(
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
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromRGBO(83, 178, 246, 1)),
                      ),
                      onPressed: () async {
                        setState(() {
                          isloading = true;
                        });

                        try {
                          var response = await DioClient()
                              .deleteAdmin("admin_auth/delete");
                          if (response != null) {
                            Navigator.pop(context);
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: "Success",
                                text: "Admin deleted successfully");

                            setState(() {
                              isloading = false;
                            });

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false);
                          } else {
                            setState(() {
                              isloading = false;
                            });

                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: "Ooops!",
                                text: "Failed to delete admin");
                          }
                        } on DioException catch (e) {
                          setState(() {
                            isloading = false;
                          });

                          print(e.message);
                        }
                      },
                      child: const Text("Yes"),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
