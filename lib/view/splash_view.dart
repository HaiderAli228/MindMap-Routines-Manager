import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/images/second.json",
                fit: BoxFit.cover, height: 300, width: 400),
            const Text(
              "Notes",
              style: TextStyle(
                  fontSize: 30,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
