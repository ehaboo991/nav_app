import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/brand_title.dart';
import '../widgets/main_button.dart';
import '../widgets/waves_painter.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // يفتح شاشة الـ login بانتقال fade ناعم
  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.aquaFoam, AppColors.aquaFoamLight],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: WavesPainter())),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Hero(
                          tag: logoHeroTag,
                          flightShuttleBuilder: logoShuttle,
                          child: AppLogo(size: 64),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BrandTitle(fontSize: 32),
                            Text(
                              'University Indoor Navigation System',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    AppColors.cyberTeal.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'جامعة مؤتة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyberTeal,
                      ),
                    ),
                    Text(
                      'MUTAH UNIVERSITY',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: AppColors.cyberTeal.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cyberTeal,
                                height: 1.1,
                              ),
                            ),
                            const BrandTitle(fontSize: 36),
                            const SizedBox(height: 8),
                            Text(
                              'Find your way around\nMutah University.',
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.3,
                                color:
                                    AppColors.cyberTeal.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: size.height * 0.40,
                      child: const _MutahImage(),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: MainButton(
                        arabic: ' تسجيل الدخول',
                        english: 'Student Login',
                        icon: Icons.person,
                        filled: true,
                        onTap: () => _openLogin(context),
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

// ======================= mutah image =======================
class _MutahImage extends StatelessWidget {
  const _MutahImage();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0.0, 0.25, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: SizedBox(
        width: double.infinity,
        child: Image.asset(
          'image/mutah.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.aquaFoam, AppColors.cyberTealLight],
                  ),
                ),
              ),
              const Positioned(left: 70, top: 50, child: Pin(size: 28)),
              const Positioned(right: 80, top: 70, child: Pin(size: 24)),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Center(child: Pin(size: 42)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}