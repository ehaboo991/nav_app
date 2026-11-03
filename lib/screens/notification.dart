import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'schedule_data.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// الوقت قبل المحاضرة اللي بيجي فيه التذكير (بالدقائق)
  static const int reminderMinutes = 15;

  static const _prefKey = 'lecture_notifications_enabled';

  /// حالة التنبيهات (الشاشة بتسمع عليه)
  static final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(true);

  /// آخر جدول انبعت، عشان نقدر نعيد الجدولة لما يتغير الخيار
  static List<Lecture> _lastLectures = [];

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'lectures_channel',
      'تنبيهات المحاضرات',
      channelDescription: 'تذكير قبل المحاضرة وعند بدايتها',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init() async {
    if (_ready) return;
    try {
      // تحميل اختيار المستخدم المحفوظ
      final prefs = await SharedPreferences.getInstance();
      enabledNotifier.value = prefs.getBool(_prefKey) ?? true;

      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission(); // Android 13+
      await android?.requestExactAlarmsPermission(); // عشان توصل بالوقت بالضبط

      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _ready = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  /// تفعيل / إلغاء تنبيهات المحاضرات
  static Future<void> setEnabled(bool value) async {
    enabledNotifier.value = value;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);

      if (value && _ready) {
        // نتأكد إن الصلاحيات لسا موجودة
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Notification setEnabled failed: $e');
    }

    await rescheduleAll(_lastLectures);
  }

  /// أقرب وقت جاي (بعد الآن) لهذا اليوم والدقيقة
  static tz.TZDateTime _next(int weekday, int minuteOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minuteOfDay ~/ 60,
      minuteOfDay % 60,
    );
    while (d.weekday != weekday || !d.isAfter(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  /// بيلغي كل الإشعارات القديمة وبيجدول من جديد حسب الجدول الحالي
  static Future<void> rescheduleAll(List<Lecture> lectures) async {
    _lastLectures = lectures; // نحفظ الجدول دايماً
    if (!_ready) return;
    try {
      await _plugin.cancelAll();

      // إذا التنبيهات مطفية، بنكتفي بالإلغاء
      if (!enabledNotifier.value) return;

      var id = 0;
      for (final l in lectures) {
        final place = l.place;

        // تذكير قبل المحاضرة
        if (l.startMin >= reminderMinutes) {
          await _schedule(
            id: id++,
            title: 'محاضرتك قربت ⏰',
            body: '${l.course} بتبدأ بعد $reminderMinutes دقيقة • $place',
            when: _next(l.weekday, l.startMin - reminderMinutes),
          );
        }

        // عند بداية المحاضرة
        await _schedule(
          id: id++,
          title: 'المحاضرة بلشت 📚',
          body: '${l.course} • $place',
          when: _next(l.weekday, l.startMin),
        );
      }
    } catch (e) {
      debugPrint('Notification scheduling failed: $e');
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // بيتكرر كل أسبوع بنفس اليوم والوقت
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}