import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes/routes/routes_name.dart';
import '../utils/app_colors.dart';

/// Splash screen that displays the app logo and name, then navigates
/// to the home screen after a short delay.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();

    // Navigates to the home screen after 4 seconds.
    Timer(
      const Duration(seconds: 4),
          () {
        Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image(image: AssetImage("assets/images/ss.png")),

            //App name text with custom styling
            Text(
              "Notes",
              style: TextStyle(
                  fontSize: 30,
                  fontFamily: "Poppins",
                  color: AppColors.themeColor,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
