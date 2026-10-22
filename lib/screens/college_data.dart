import 'package:flutter/material.dart';

class College {
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final int building; // رقم المبنى على الخريطة

  const College({
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.building,
  });
}

// ⚠️ بيانات مؤقتة: عدّل الأسماء وأرقام المباني حسب الخريطة الفعلية
const List<College> colleges = [
 College(
  nameAr: 'كلية تكنولوجيا المعلومات',
  nameEn: 'Faculty of Information Technology',
  icon: Icons.code_rounded,
  building: 11, // ⚠️ عدّل الرقم حسب الخريطة
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
  nameAr: 'كلية العلوم الطبية المساندة',
  nameEn: 'Faculty of Allied Medical Sciences',
  icon: Icons.biotech_outlined, // مجهر/مختبرات، الأقرب للتخصصات المساندة
  building: 0,
),
  College(
    nameAr:'كلية العلوم1',
    nameEn: 'Faculty of Science',
    icon: Icons.science_outlined,
    building: 0,
  ),
   College(
    nameAr:'كلية العلوم2',
    nameEn: 'Faculty of Science',
    icon: Icons.science_outlined,
    building: 0,
  ),
  College(
  nameAr: 'كلية الزراعة',
  nameEn: 'Faculty of Agriculture',
  icon: Icons.park_outlined, // جرار زراعي، الأنسب مباشرة
  building: 0,
),
  College(
    nameAr: 'كلية الآداب',
    nameEn: 'Faculty of Arts',
    icon: Icons.menu_book_outlined,
    building: 0,
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
      nameAr: 'كلية الهندسة',
      nameEn: 'Faculty of Engineering',
      icon: Icons.cast_for_education_outlined,
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
  nameAr: 'كلية العلوم الاجتماعية',
  nameEn: 'Faculty of Social Sciences',
  icon: Icons.diversity_3_outlined,
  building: 0,
),
  College(
    nameAr: 'كلية الصيدلة',
    nameEn: 'Faculty of Pharmacy',
    icon: Icons.medication_outlined,
    building: 0,
  ),
  College(
    nameAr: 'كلية التمريض',
    nameEn: 'Faculty of Nursing',
    icon: Icons.health_and_safety_outlined,
    building: 0,
  ),
  College(
  nameAr: 'كلية الحقوق',
  nameEn: 'Faculty of Law',
  icon: Icons.gavel_outlined,
  building: 8, // ⚠️ عدّل الرقم حسب الخريطة
),
];