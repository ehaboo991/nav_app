import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

import 'screens/home_page_screens.dart'; // عشان appLightTheme / appDarkTheme
import 'screens/notification.dart'; // 👈 جديد
import 'screens/schedule_data.dart'; // 👈 جديد
import 'screens/splash_screen.dart';
import 'widgets/motion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 جديد
  await NotificationService.init(); // 👈 جديد: لازم قبل load
  await ScheduleStore.load(); // 👈 جديد: بيحمّل الجدول وبيجدول الإشعارات
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: appLightTheme,
      duration: const Duration(milliseconds: 600),
      builder: (context, theme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        // نضيف الانتقال الناعم فوق الثيم (فاتح/داكن) بدون ما نخرب عليه
        theme: theme.copyWith(pageTransitionsTheme: appPageTransitions),
        home: const SplashScreen(),
      ),
    );
  }
}