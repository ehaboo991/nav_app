import 'dart:async';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/brand_title.dart';
import '../widgets/loading_dots.dart';
import '../widgets/route_map.dart';
import '../widgets/waves_painter.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dots;
  late final AnimationController _intro;
  late final AnimationController _route;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _route = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dots.dispose();
    _intro.dispose();
    _route.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleFade = CurveTween(
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    ).animate(_intro);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.aquaFoam, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: WavesPainter()),
            ),
            // SizedBox بعرض الشاشة كاملة عشان الـ Column يتوسّط أفقياً
            // (بدونه الـ Column بياخد عرض أعرض عنصر وبيلزق على اليسار)
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // المحتوى الأساسي بنص الشاشة (أفقياً وعمودياً)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Hero(
                              tag: logoHeroTag,
                              flightShuttleBuilder: logoShuttle,
                              child: AnimatedAppLogo(controller: _intro),
                            ),
                            const SizedBox(height: 12),
                            FadeTransition(
                              opacity: titleFade,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const BrandTitle(fontSize: 44),
                                  const SizedBox(height: 4),
                                  Text(
                                    'University Indoor Navigation System',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cyberTeal
                                          .withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'جامعة مؤتة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyberTeal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MUTAH UNIVERSITY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 3,
                                color: AppColors.cyberTeal.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 36),
                            const Text(
                              'Find your way around',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                color: AppColors.cyberTeal,
                              ),
                            ),
                            const Text(
                              'Mutah University.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cyberTeal,
                              ),
                            ),

                            // تم تعطيل RouteMap مؤقتاً للتحقق من زوال مشكلة التجميد والشاشة السوداء
                            /*
                            Expanded(
                              flex: 3,
                              child: RouteMap(progress: _route),
                            ),
                            */
                          ],
                        ),
                      ),
                    ),

                    // نقاط التحميل بأسفل الشاشة وبالنص
                    LoadingDots(controller: _dots),
                    const SizedBox(height: 8),
                    Text(
                      'Loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.cyberTeal.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}