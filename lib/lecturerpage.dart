import 'package:flutter/material.dart';

class LecturerPage extends StatelessWidget {
  const LecturerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            const Text(
              "Welcome Mr/Mrs Lecturer!",
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
                  gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent, Colors.blue])),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Courses",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Introduction to Programming - YR 1"),
                  SizedBox(height: 10),
                  Text("Data Structures and Algorithms - YR 3"),
                  SizedBox(height: 10),
                  Text("Software Engineering - YR 4"),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
