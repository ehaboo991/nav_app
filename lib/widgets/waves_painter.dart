import 'package:flutter/material.dart';
import '../app_colors.dart';

class WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final top = Paint()..color = AppColors.cyberTeal.withValues(alpha: 0.12);
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.55, 0)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.04,
        size.width * 0.15, size.height * 0.1,
      )
      ..quadraticBezierTo(
        size.width * 0.05, size.height * 0.14,
        0, size.height * 0.13,
      )
      ..close();
    canvas.drawPath(topPath, top);

    final bottom = Paint()..color = AppColors.cyberTealLight.withValues(alpha: 0.18);
    final bottomPath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.8, size.height * 0.9,
        size.width * 0.65, size.height * 0.96,
      )
      ..quadraticBezierTo(
        size.width * 0.6, size.height * 0.98,
        size.width * 0.55, size.height,
      )
      ..close();
    canvas.drawPath(bottomPath, bottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}