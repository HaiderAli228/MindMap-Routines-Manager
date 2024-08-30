import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({required this.text, super.key, required this.onTapFunction});
  final String text;
  final VoidCallback onTapFunction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapFunction,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.themeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 50,
        child: Text(
          text,
          style: const TextStyle(
              color: AppColors.themeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins"),
        ),
      ),
    );
  }
}
