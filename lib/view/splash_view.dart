import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:notes/routes/routes_name.dart';
import '../utils/app_colors.dart';

/// Splash screen that displays the app logo and name on mobile, then navigates
/// to the home screen. Skips the splash screen on web and directly shows home.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // If the platform is web, directly navigate to the home screen.
      Future.microtask(
          () => Navigator.pushReplacementNamed(context, RoutesName.homeScreen));
    } else {
      // If the platform is mobile, show the splash screen for 4 seconds.
      Timer(
        const Duration(seconds: 4),
        () {
          Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If it's web, return an empty container (since splash won't be shown)
    if (kIsWeb) {
      return const SizedBox.shrink(); // Return an empty widget for the web
    }

    // Fetch screen size to make the UI responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine scaling factor for logo and text based on screen size
    final logoHeight =
        screenHeight * 0.3; // 30% of the screen height for the logo
    final fontSize = screenWidth * 0.08; // Font size 8% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with dynamic height based on screen size
            Image(
              image: const AssetImage("assets/images/ss.png"),
              height: logoHeight, // Adjusts logo size
              fit: BoxFit.contain,
            ),
            SizedBox(
                height: screenHeight *
                    0.05), // Add dynamic spacing between logo and text

            // App name text with dynamic font size based on screen size
            Text(
              "Notes",
              style: TextStyle(
                fontSize: fontSize, // Dynamically scaled font size
                fontFamily: "Poppins",
                color: AppColors.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
