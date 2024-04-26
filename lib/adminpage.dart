import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                const Text(
                  "Welcome admin!",
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                const Text(
                  "What would you like to do today?",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: screenWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [
                        Colors.blue,
                        Colors.blueAccent,
                        Colors.blue
                      ])),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Students",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Add student"),
                      SizedBox(height: 10),
                      Text("Remove student"),
                      SizedBox(height: 10),
                      Text("Edit student details"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: screenWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [
                        Colors.green,
                        Colors.greenAccent,
                        Colors.green
                      ])),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Lecturers",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Add lecturer"),
                      SizedBox(height: 10),
                      Text("Remove lecturer"),
                      SizedBox(height: 10),
                      Text("Edit lecturer details"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: screenWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [
                        Colors.red,
                        Colors.redAccent,
                        Colors.redAccent,
                      ])),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Admins",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Add admin"),
                      SizedBox(height: 10),
                      Text("Remove admin"),
                      SizedBox(height: 10),
                      Text("Edit admin details"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
