import 'package:flutter/material.dart';

/// بداية ونهاية الدوام الرسمي (بالدقائق من منتصف الليل)
const int kDayStartMin = 8 * 60;
const int kDayEndMin = 17 * 60;

class Room {
  final String id;
  final String name;
  final int building; // رقم المبنى
  final int floor;
  final String type; // 'hall' | 'lab'

  const Room(this.id, this.name, this.building, this.floor, this.type);

  IconData get icon =>
      type == 'lab' ? Icons.computer_rounded : Icons.meeting_room_rounded;
}

/// حجز أسبوعي متكرر: القاعة مشغولة بهالفترة بهاليوم
class RoomBooking {
  final String roomId;
  final int weekday; // DateTime.weekday: الأحد 7، الإثنين 1 ... الخميس 4
  final int startMin;
  final int endMin;

  const RoomBooking(this.roomId, this.weekday, this.startMin, this.endMin);
}

// ═══════════════════════════════════════════════════════════════
//  ⚠️ بيانات تجريبية — استبدلها ببيانات القاعات الحقيقية لجامعة مؤتة
//  (الأرقام بالدقائق: 8:00 = 480، 9:30 = 570، 11:00 = 660 ...)
//  مصدر الجدول الحقيقي: جدول القاعات من القبول والتسجيل أو من الكليات.
// ═══════════════════════════════════════════════════════════════

const List<Room> kRooms = [
  Room('b8-101', 'قاعة 101', 8, 1, 'hall'),
  Room('b8-102', 'قاعة 102', 8, 1, 'hall'),
  Room('b8-201', 'قاعة 201', 8, 2, 'hall'),
  Room('b8-lab1', 'مختبر حاسوب 1', 8, 1, 'lab'),
  Room('b11-101', 'قاعة 101', 11, 1, 'hall'),
  Room('b11-102', 'قاعة 102', 11, 1, 'hall'),
  Room('b11-204', 'قاعة 204', 11, 2, 'hall'),
];

// الأحد 7 | الإثنين 1 | الثلاثاء 2 | الأربعاء 3 | الخميس 4
const List<RoomBooking> kRoomBookings = [
  // مبنى 8 - قاعة 101 (أحد/ثلاثاء/خميس)
  RoomBooking('b8-101', 7, 480, 570),
  RoomBooking('b8-101', 7, 600, 690),
  RoomBooking('b8-101', 2, 480, 570),
  RoomBooking('b8-101', 2, 720, 810),
  RoomBooking('b8-101', 4, 480, 570),
  // قاعة 102
  RoomBooking('b8-102', 7, 540, 630),
  RoomBooking('b8-102', 7, 780, 870),
  RoomBooking('b8-102', 1, 600, 690),
  RoomBooking('b8-102', 3, 600, 690),
  // قاعة 201
  RoomBooking('b8-201', 7, 480, 660),
  RoomBooking('b8-201', 1, 720, 840),
  // مختبر حاسوب 1
  RoomBooking('b8-lab1', 7, 600, 720),
  RoomBooking('b8-lab1', 7, 780, 900),
  RoomBooking('b8-lab1', 2, 540, 660),
  // مبنى 11
  RoomBooking('b11-101', 7, 480, 570),
  RoomBooking('b11-101', 7, 660, 750),
  RoomBooking('b11-102', 1, 480, 600),
  RoomBooking('b11-102', 3, 480, 600),
  RoomBooking('b11-204', 7, 600, 690),
  RoomBooking('b11-204', 2, 600, 690),
  RoomBooking('b11-204', 4, 600, 690),
];

class RoomStatus {
  final Room room;
  final bool free;

  /// إذا مشغولة: وقت ما بتتفضى. إذا فاضية: وقت أول حجز جاي (null = لنهاية اليوم)
  final int? until;

  const RoomStatus(this.room, this.free, this.until);
}

RoomStatus roomStatusAt(Room r, int weekday, int min) {
  final todays = kRoomBookings
      .where((b) => b.roomId == r.id && b.weekday == weekday)
      .toList()
    ..sort((a, b) => a.startMin.compareTo(b.startMin));

  for (final b in todays) {
    if (min >= b.startMin && min < b.endMin) {
      return RoomStatus(r, false, b.endMin);
    }
  }
  final next = todays.where((b) => b.startMin > min).firstOrNull;
  return RoomStatus(r, true, next?.startMin);
}