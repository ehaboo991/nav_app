import 'package:flutter/material.dart';

import 'screens/home_page_screens.dart'; // عشان themeNotifier
import 'screens/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
        darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        home: const SplashScreen(), // ← التعديل الأساسي
      ),
    );
  }
}