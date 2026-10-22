import 'package:flutter/material.dart';
import '../app_colors.dart';

class MainButton extends StatelessWidget {
  final String arabic, english;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const MainButton({
    super.key,
    required this.arabic,
    required this.english,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.aquaFoam : AppColors.cyberTeal;
    return Material(
      color: filled ? AppColors.cyberTeal : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppColors.cyberTeal, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arabic,
                      style: TextStyle(
                        color: fg,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(english, style: TextStyle(color: fg.withOpacity(0.85))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}