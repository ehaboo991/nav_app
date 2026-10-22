import 'package:flutter/material.dart';
import '../app_colors.dart';

class BrandTitle extends StatelessWidget {
  final double fontSize;
  const BrandTitle({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        children: [
          TextSpan(
            text: 'Mutah',
            style: TextStyle(color: AppColors.cyberTeal),
          ),
          TextSpan(
            text: '-Nav',
            style: TextStyle(color: AppColors.cyberTealLight),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}