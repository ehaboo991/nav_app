import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'college_data.dart';
import 'notification.dart'; // 👈 جديد

// ───────────────────────── أيام وتنسيق ─────────────────────────

/// أيام الدوام بترتيب الأسبوع عندنا (الأحد → الخميس).
/// القيم هي DateTime.weekday: الأحد 7، الإثنين 1، الثلاثاء 2، الأربعاء 3، الخميس 4
const List<int> kStudyDays = [7, 1, 2, 3, 4];

const Map<int, String> kDayNames = {
  7: 'الأحد',
  1: 'الإثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
};

/// 570 → "9:30 ص"
String fmtTime(int min) {
  final h24 = min ~/ 60;
  final m = min % 60;
  final suffix = h24 >= 12 ? 'م' : 'ص';
  var h = h24 % 12;
  if (h == 0) h = 12;
  return '$h:${m.toString().padLeft(2, '0')} $suffix';
}

/// 90 → "ساعة و 30 د" | 45 → "45 د"
String fmtDuration(int min) {
  if (min < 60) return '$min د';
  final h = min ~/ 60;
  final m = min % 60;
  final hText = h == 1 ? 'ساعة' : '$h ساعات';
  return m == 0 ? hText : '$hText و $m د';
}

/// الكليات بدون تكرار (نفس منطق شاشة ابدأ الملاحة)
List<College> uniqueColleges() {
  final unique = <String, College>{};
  for (final c in colleges) {
    unique.putIfAbsent(c.nameAr, () => c);
  }
  return unique.values.toList();
}

// ───────────────────────── المحاضرة ─────────────────────────

class Lecture {
  final String id;
  final String course;
  final String room; // مثال: "قاعة 204" (نص حر)
  final String buildingName; // اسم الكلية/المبنى (nameAr)
  final int building; // رقم المبنى، 0 = غير محدد
  final int weekday; // DateTime.weekday
  final int startMin; // دقائق من منتصف الليل
  final int endMin;

  const Lecture({
    required this.id,
    required this.course,
    required this.room,
    required this.buildingName,
    required this.building,
    required this.weekday,
    required this.startMin,
    required this.endMin,
  });

  String get place => room.isEmpty ? buildingName : '$room • $buildingName';

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'room': room,
        'buildingName': buildingName,
        'building': building,
        'weekday': weekday,
        'startMin': startMin,
        'endMin': endMin,
      };

  factory Lecture.fromJson(Map<String, dynamic> j) => Lecture(
        id: j['id'] as String,
        course: j['course'] as String,
        room: (j['room'] as String?) ?? '',
        buildingName: j['buildingName'] as String,
        building: (j['building'] as num).toInt(),
        weekday: (j['weekday'] as num).toInt(),
        startMin: (j['startMin'] as num).toInt(),
        endMin: (j['endMin'] as num).toInt(),
      );
}

// ───────────────────────── التخزين المحلي ─────────────────────────

class ScheduleStore {
  ScheduleStore._();

  static const String _key = 'lectures_v1';

  static final ValueNotifier<List<Lecture>> lectures =
      ValueNotifier<List<Lecture>>(const <Lecture>[]);

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      lectures.value = (jsonDecode(raw) as List)
          .map((e) => Lecture.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      // 👈 جديد: جدولة الإشعارات للمحاضرات المحفوظة
      await NotificationService.rescheduleAll(lectures.value);
    } catch (_) {
      // بيانات تالفة: منبدأ بجدول فاضي بدل ما يكرش التطبيق
    }
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(lectures.value.map((l) => l.toJson()).toList()),
      );
    } catch (_) {}
    // 👈 جديد: تحديث الإشعارات بعد أي إضافة / تعديل / حذف
    await NotificationService.rescheduleAll(lectures.value);
  }

  static Future<void> add(Lecture l) => addAll([l]);

  static Future<void> addAll(List<Lecture> list) async {
    lectures.value = [...lectures.value, ...list];
    await _save();
  }

  static Future<void> replace(Lecture l) async {
    lectures.value = [
      for (final o in lectures.value) o.id == l.id ? l : o,
    ];
    await _save();
  }

  static Future<void> remove(String id) async {
    lectures.value = lectures.value.where((l) => l.id != id).toList();
    await _save();
  }

  /// محاضرات يوم معيّن مرتبة حسب الوقت
  static List<Lecture> forDay(int weekday) {
    final list = lectures.value.where((l) => l.weekday == weekday).toList()
      ..sort((a, b) => a.startMin.compareTo(b.startMin));
    return list;
  }

  /// أول محاضرة بنفس اليوم بتتداخل مع [c] (أو null)
  static Lecture? conflict(Lecture c, {String? ignoreId}) {
    return lectures.value
        .where((o) =>
            o.id != ignoreId &&
            o.weekday == c.weekday &&
            c.startMin < o.endMin &&
            o.startMin < c.endMin)
        .firstOrNull;
  }
}

// ───────────────────────── المحاضرة الجاية ─────────────────────────

class NextLecture {
  final Lecture lecture;
  final DateTime start;
  final bool ongoing;

  /// 0 = اليوم، 1 = بكرة، ...
  final int dayOffset;

  const NextLecture(this.lecture, this.start, this.ongoing, this.dayOffset);
}

NextLecture? findNextLecture(List<Lecture> all, DateTime now) {
  if (all.isEmpty) return null;
  final nowMin = now.hour * 60 + now.minute;

  for (var d = 0; d <= 7; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    final todays = all.where((l) => l.weekday == day.weekday).toList()
      ..sort((a, b) => a.startMin.compareTo(b.startMin));

    for (final l in todays) {
      final start = day.add(Duration(minutes: l.startMin));
      if (d == 0) {
        if (nowMin >= l.endMin) continue; // خلصت
        return NextLecture(l, start, nowMin >= l.startMin, 0);
      }
      return NextLecture(l, start, false, d);
    }
  }
  return null;
}

// ───────────────────────── تقدير وقت المشي ─────────────────────────

/// تقدير وقت المشي من إحداثيات الخريطة (مش مسار A* حقيقي).
///
/// ⚠️ معايرة: عدّل [mapWidthMeters] حسب العرض الحقيقي اللي بتغطيه صورة MUU.jpeg،
/// وضيف مواقع باقي المباني بـ [buildingSpots] (نسبة 0..1 من عرض/ارتفاع الصورة).
class Walk {
  Walk._();

  /// العرض الحقيقي التقريبي للخريطة بالمتر (افتراضي — لازم تعايره)
  static const double mapWidthMeters = 500;

  /// نسبة عرض/ارتفاع صورة الخريطة (نفس AspectRatio بـ map_viewer_screen)
  static const double _aspect = 1058 / 1322;

  /// سرعة المشي: ~80 متر بالدقيقة
  static const double _metersPerMin = 80;

  /// المسار الحقيقي أطول من الخط المستقيم
  static const double _detour = 1.3;

  /// نقطة البداية الافتراضية (البوابة الشمالية، نفس بداية المسارات بالخريطة)
  static const Offset gate = Offset(.577, .922);

  /// مواقع المباني على الخريطة. موجود حالياً بس 8 و 11 (آخر نقطة بمساراتهم).
  /// ضيف الباقي هون: رقم المبنى: Offset(x, y)
  static const Map<int, Offset> buildingSpots = {
    8: Offset(.278, .590),
    11: Offset(.439, .405),
  };

  /// إذا موقع المبنى مجهول
  static const int defaultMinutes = 6;

  static int _minutes(Offset a, Offset b) {
    final w = mapWidthMeters;
    final h = w / _aspect;
    final dx = (a.dx - b.dx) * w;
    final dy = (a.dy - b.dy) * h;
    final meters = math.sqrt(dx * dx + dy * dy) * _detour;
    return math.max(1, (meters / _metersPerMin).ceil());
  }

  /// من موقعك (أو البوابة إذا ما حددت) لحد المبنى. null إذا موقع المبنى مجهول.
  static int? toBuilding(Offset? from, int building) {
    final spot = buildingSpots[building];
    if (spot == null) return null;
    return _minutes(from ?? gate, spot);
  }

  /// بين مبنيين. null إذا واحد منهم مجهول.
  static int? between(int a, int b) {
    if (a == b && a != 0) return 2;
    final pa = buildingSpots[a];
    final pb = buildingSpots[b];
    if (pa == null || pb == null) return null;
    return _minutes(pa, pb);
  }
}