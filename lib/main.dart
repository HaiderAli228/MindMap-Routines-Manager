import 'package:flutter/material.dart';
import 'package:notes/utils/app_colors.dart';
import 'package:notes/view/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.themeColor,
        useMaterial3: true,
      ),
      home : const HomeView(),
    );
  }
}
