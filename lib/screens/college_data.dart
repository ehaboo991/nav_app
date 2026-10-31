import 'package:flutter/material.dart';

class College {
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final int building; // رقم المبنى على الخريطة
  final String? imagePath; // مسار الصورة (اختياري)

  const College({
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.building,
    this.imagePath,
  });
}

// ⚠️ بيانات مؤقتة: عدّل الأسماء وأرقام المباني حسب الخريطة الفعلية
const List<College> colleges = [
  College(
    nameAr: 'كلية تكنولوجيا المعلومات',
    nameEn: 'Faculty of Information Technology',
    icon: Icons.code_rounded,
    building: 11, // ⚠️ عدّل الرقم حسب الخريطة
    imagePath: 'assets/image/it.png', // ⚠️ عدّل المسار لصورتك الفعلية
  ),
  College(
    nameAr: 'كلية الهندسة',
    nameEn: 'Faculty of Engineering',
    icon: Icons.engineering_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الطب البشري',
    nameEn: 'Faculty of Medicine',
    icon: Icons.medical_services_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية طب الاسنان',
    nameEn: 'Faculty of Dentistry',
    icon: Icons.health_and_safety_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية العلوم1',
    nameEn: 'Faculty of Science',
    icon: Icons.science_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية العلوم2',
    nameEn: 'Faculty of Science',
    icon: Icons.science_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الآداب',
    nameEn: 'Faculty of Arts',
    icon: Icons.menu_book_outlined,
    building: 0,
    imagePath: 'assets/image/lit.jpg', // ✅ صورة كلية الآداب
  ),
  College(
    nameAr: 'كلية الشريعة',
    nameEn: 'Faculty of Sharia',
    icon: Icons.mosque_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الأعمال',
    nameEn: 'Faculty of Business',
    icon: Icons.business_center_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الرياضة',
    nameEn: 'Faculty of Sports Sciences',
    icon: Icons.sports_soccer_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية العلوم التربوية',
    nameEn: 'Faculty of Educational Sciences',
    icon: Icons.school_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الصيدلة',
    nameEn: 'Faculty of Pharmacy',
    icon: Icons.medication_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية الحقوق',
    nameEn: 'Faculty of Law',
    icon: Icons.gavel_outlined,
    building: 8, // ⚠️ عدّل الرقم حسب الخريطة
  ),
];

/// بيوحّد الكتابة قبل المقارنة: بيشيل المسافات والتطويل، وبيوحّد
/// الألف (أ إ آ → ا) والتاء المربوطة والألف المقصورة.
/// عشان "كلية العلوم 1" (من الخريطة) تطابق "كلية العلوم1" (من college_data)
String normalizeAr(String s) => s
    .replaceAll(RegExp(r'[\s\u0640]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي');

/// بيدور على الكلية المطابقة لاسم مبنى (من خريطة الكامبس مثلاً).
/// تطابق تام أولاً، وبعدين تطابق جزئي (مثل "كلية الطب" ↔ "كلية الطب البشري").
/// بيرجّع null إذا المكان مش كلية (مكتبة، بنك، ...).
College? findCollegeByName(String name) {
  final target = normalizeAr(name);
  if (target.isEmpty) return null;

  for (final c in colleges) {
    if (normalizeAr(c.nameAr) == target) return c;
  }
  for (final c in colleges) {
    final n = normalizeAr(c.nameAr);
    if (n.contains(target) || target.contains(n)) return c;
  }
  return null;
}