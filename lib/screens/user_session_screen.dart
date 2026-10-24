import 'package:flutter/foundation.dart';

/// بيانات المستخدم المسجّل دخوله
class UserProfile {
  final String name;
  final String studentId;
  final String college;
  final String major;

  const UserProfile({
    required this.name,
    required this.studentId,
    required this.college,
    required this.major,
  });

  UserProfile copyWith({
    String? name,
    String? studentId,
    String? college,
    String? major,
  }) {
    return UserProfile(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      college: college ?? this.college,
      major: major ?? this.major,
    );
  }
}

/// المستخدم الحالي. null = ما في حدا مسجّل دخول.
/// أي شاشة بتسمع عليه بتتحدّث تلقائياً (مثل شاشة حسابي).
final ValueNotifier<UserProfile?> userNotifier =
    ValueNotifier<UserProfile?>(null);

/// بتنادى من شاشة تسجيل الدخول لما ينجح الدخول
void signIn(UserProfile profile) {
  userNotifier.value = profile;
}

/// بتنادى عند تسجيل الخروج
void signOut() {
  userNotifier.value = null;
}