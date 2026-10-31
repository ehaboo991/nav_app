import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

import 'screens/home_page_screens.dart'; // عشان appLightTheme / appDarkTheme
import 'screens/notification.dart'; 
import 'screens/schedule_data.dart'; 
import 'screens/splash_screen.dart';
import 'screens/campus_map_screen.dart'; // 👈 تم إضافة استيراد شاشة خريطة الكليات والمباني
import 'widgets/motion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await NotificationService.init(); 
  await ScheduleStore.load(); 
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
        home: const SplashScreen(), // ستبقى شاشة السبلاش (أو البداية) هي أول ما يظهر بالتطبيق
      ),
    );
  }
}