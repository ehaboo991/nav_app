import 'package:flutter/material.dart';

import 'home_page_screens.dart' show cyberTeal, aquaFoam;

/// ألوان الشاشات الجديدة (الجدول، القاعات الفاضية، كرت المحاضرة).
/// مشتقة من cyberTeal و aquaFoam، فبتتبع الباليت المختارة (kPalette) تلقائياً.
class AppPal {
  final bool dark;
  const AppPal._(this.dark);

  factory AppPal.of(BuildContext context) =>
      AppPal._(Theme.of(context).brightness == Brightness.dark);

  Color get bg => dark
      ? Color.lerp(cyberTeal, Colors.black, .55)!
      : Color.lerp(aquaFoam, Colors.white, .8)!;

  Color get surface =>
      dark ? Color.lerp(bg, aquaFoam, .06)! : Colors.white;

  Color get border => dark
      ? aquaFoam.withAlpha(40)
      : Color.lerp(aquaFoam, cyberTeal, .08)!;

  Color get title => dark ? aquaFoam : cyberTeal;
  Color get sub => title.withAlpha(165);

  Color get actionBg =>
      dark ? aquaFoam.withAlpha(26) : Color.lerp(aquaFoam, Colors.white, .45)!;

  /// نهاية التدرج للهيدر والكروت الغامقة
  Color get deep => Color.lerp(cyberTeal, aquaFoam, .14)!;

  Color get primaryBg => dark ? aquaFoam : cyberTeal;
  Color get onPrimary => dark ? cyberTeal : aquaFoam;

  Color get warn =>
      dark ? const Color(0xFFFFC857) : const Color(0xFFB36B00);
  Color get danger => const Color(0xFFD64545);
}