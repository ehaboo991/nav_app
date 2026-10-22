import 'package:flutter/material.dart';
import '../app_colors.dart';

// ---------- Hero ----------
const String logoHeroTag = 'app-logo';

Widget logoShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  return const FittedBox(child: AppLogo(size: 110));
}

// ---------- Pin ----------
class Pin extends StatelessWidget {
  final double size;
  const Pin({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.location_on, size: size, color: AppColors.cyberTeal);
}

// ---------- Logo ----------
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.42;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(Icons.location_on, size: size, color: AppColors.cyberTeal),
          Positioned(
            top: size * 0.2,
            child: Container(
              width: inner,
              height: inner,
              decoration: const BoxDecoration(
                color: AppColors.aquaFoam,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance,
                size: inner * 0.6,
                color: AppColors.cyberTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Animated Logo ----------
class AnimatedAppLogo extends StatelessWidget {
  final Animation<double> controller;
  final double size;
  const AnimatedAppLogo({super.key, required this.controller, this.size = 110});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.42;

    final drop = CurveTween(
      curve: const Interval(0.0, 0.5, curve: Curves.bounceOut),
    ).animate(controller);

    final dropFade = CurveTween(
      curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
    ).animate(controller);

    final pop = CurveTween(
      curve: const Interval(0.5, 0.75, curve: Curves.easeOutBack),
    ).animate(controller);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: drop,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -(1 - drop.value) * 260),
          child: child,
        ),
        child: FadeTransition(
          opacity: dropFade,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(Icons.location_on, size: size, color: AppColors.cyberTeal),
              Positioned(
                top: size * 0.2,
                child: ScaleTransition(
                  scale: pop,
                  child: Container(
                    width: inner,
                    height: inner,
                    decoration: const BoxDecoration(
                      color: AppColors.aquaFoam,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      size: inner * 0.6,
                      color: AppColors.cyberTeal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}