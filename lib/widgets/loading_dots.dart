import 'package:flutter/material.dart';
import '../app_colors.dart';

class LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const LoadingDots({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final active = (controller.value * 4).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final on = i == active;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: on ? 10 : 8,
              height: on ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on
                    ? AppColors.cyberTeal
                    : AppColors.cyberTeal.withValues(alpha: 0.25),
              ),
            );
          }),
        );
      },
    );
  }
}