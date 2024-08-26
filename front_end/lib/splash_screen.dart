import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Auth/api.dart';
import 'Pages/admin_page.dart';
import 'Pages/lecturer_page.dart';
import 'Pages/login.dart';
import 'Pages/student_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String pageLoggedIn = "";
  Future getValidationData() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    String? accesstoken = localStorage.getString('access_token');
    String? page = localStorage.getString('page');

    print(accesstoken);
    print(page);

    setState(() {
      accessToken = accesstoken;
      pageLoggedIn = page ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    getValidationData().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration.zero, _navigateBasedOnToken);
      });
    });
  }

  void _navigateBasedOnToken() {
    if (accessToken != null) {
      if (pageLoggedIn == "student") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StudentPage()),
          (route) => false,
        );
      } else if (pageLoggedIn == "lecturer") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LecturerPage()),
          (route) => false,
        );
      } else if (pageLoggedIn == "admin") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminPage()),
          (route) => false,
        );
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
