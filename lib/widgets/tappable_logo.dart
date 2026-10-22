import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'app_logo.dart';

class TappableLogo extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  /// حط هون شعار الجامعة لما يكون جاهز، مثلاً:
  /// Image.asset('image/logo.png', width: 150)
  final Widget? child;

  const TappableLogo({
    super.key,
    required this.onTap,
    this.size = 150,
    this.child,
  });

  @override
  State<TappableLogo> createState() => _TappableLogoState();
}

class _TappableLogoState extends State<TappableLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // الوضع الغامق: دائرة Aqua Foam عشان الشعار الغامق يبين
              // الوضع الفاتح: دائرة بيضاء
              color: dark
                  ? AppColors.aquaFoam.withOpacity(0.85)
                  : Colors.white.withOpacity(0.75),
              boxShadow: [
                BoxShadow(
                  color: (dark ? AppColors.aquaFoam : AppColors.cyberTeal)
                      .withOpacity(0.25 + 0.25 * t),
                  blurRadius: 24 + 20 * t,
                  spreadRadius: 4 + 10 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child ?? AppLogo(size: widget.size),
      ),
    );
  }
}