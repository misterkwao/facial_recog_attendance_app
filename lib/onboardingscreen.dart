import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              LottieBuilder.network(
                "https://lottie.host/0013d07a-726b-4fbb-8556-dfd6b8521ce2/5OV98R3tSe.json",
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return CircularProgressIndicator(color: Colors.red[700]);
                },
              ),
              SizedBox(height: screenHeight * 0.1),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Scan your",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "face and mark",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "attendance",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 30,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              InkWell(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.6,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(1, 1))
                      ]),
                  child: const Text(
                    "Scan face",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
