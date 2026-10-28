import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

import 'screens/home_page_screens.dart'; // عشان appLightTheme / appDarkTheme
import 'screens/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: appLightTheme,
      duration: const Duration(milliseconds: 600), // أبطأ = رقم أكبر
      builder: (context, theme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme, // الباكج بيبدّل هالثيم بنفسه (فاتح/داكن)
        home: const SplashScreen(), // ← التعديل الأساسي
      ),
    );
  }
}