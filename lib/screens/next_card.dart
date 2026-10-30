import 'dart:async';

import 'package:flutter/material.dart';

import 'app_pallete.dart';
import 'home_page_screens.dart' show cyberTeal, aquaFoam;
import 'map_viewer_screen.dart';
import 'schedule_data.dart';
import 'user_location.dart';

/// كرت "محاضرتك الجاية" بالصفحة الرئيسية
class NextLectureCard extends StatefulWidget {
  final VoidCallback onOpenSchedule;

  const NextLectureCard({super.key, required this.onOpenSchedule});

  @override
  State<NextLectureCard> createState() => _NextLectureCardState();
}

class _Status {
  final String text;
  final bool urgent;
  final IconData icon;
  const _Status(this.text, this.urgent, this.icon);
}

class _NextLectureCardState extends State<NextLectureCard> {
  Timer? _timer;

  static const Color _urgent = Color(0xFFFFC857);

  @override
  void initState() {
    super.initState();
    // تحديث كل 30 ثانية عشان العدّ التنازلي و"اطلع الآن" يضلوا صح
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigate(Lecture l) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapViewerScreen(
          destination: l.buildingName,
          buildingNumber: l.building,
        ),
      ),
    );
  }

  _Status _status(NextLecture n, DateTime now, Offset? loc) {
    final l = n.lecture;
    final nowMin = now.hour * 60 + now.minute;

    if (n.ongoing) {
      final ago = nowMin - l.startMin;
      final left = l.endMin - nowMin;
      return _Status(
        'المحاضرة شغّالة: بدأت قبل $ago د وبتخلص بعد ${fmtDuration(left)}',
        false,
        Icons.play_circle_outline_rounded,
      );
    }

    if (n.dayOffset > 0) {
      final when = n.dayOffset == 1
          ? 'بكرة'
          : 'يوم ${kDayNames[n.start.weekday] ?? ''}';
      return _Status(
        'بتبدأ $when الساعة ${fmtTime(l.startMin)}',
        false,
        Icons.event_available_rounded,
      );
    }

    final toStart = n.start.difference(now).inMinutes;
    final est = Walk.toBuilding(loc, l.building);
    final walk = est ?? Walk.defaultMinutes;
    final approx = est == null ? ' (تقريبي)' : '';
    final leaveIn = toStart - walk;

    if (leaveIn <= 0) {
      return _Status(
        'اطلع الآن! المشي ~$walk د$approx والمحاضرة بعد ${fmtDuration(toStart < 0 ? 0 : toStart)}',
        true,
        Icons.directions_run_rounded,
      );
    }
    return _Status(
      'اطلع بعد ${fmtDuration(leaveIn)} • المشي ~$walk د$approx',
      false,
      Icons.directions_walk_rounded,
    );
  }

  String _label(NextLecture n) {
    if (n.ongoing) return 'محاضرة جارية الآن';
    if (n.dayOffset == 0) return 'محاضرتك الجاية اليوم';
    if (n.dayOffset == 1) return 'محاضرتك الجاية بكرة';
    return 'محاضرتك الجاية يوم ${kDayNames[n.start.weekday] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPal.of(context);

    return ValueListenableBuilder<List<Lecture>>(
      valueListenable: ScheduleStore.lectures,
      builder: (context, all, _) => ValueListenableBuilder<Offset?>(
        valueListenable: userLocationNotifier,
        builder: (context, loc, _) {
          final now = DateTime.now();
          final next = findNextLecture(all, now);
          return next == null ? _empty(p) : _card(p, next, now, loc);
        },
      ),
    );
  }

  Widget _empty(AppPal p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: p.actionBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.calendar_month_rounded, color: p.title),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أضف جدولك الدراسي',
                  style: TextStyle(
                    color: p.title,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'بنعرفك محاضرتك الجاية ووقت الطلعة إلها',
                  style: TextStyle(color: p.sub, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: widget.onOpenSchedule,
            style: FilledButton.styleFrom(
              backgroundColor: p.primaryBg,
              foregroundColor: p.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('أضف'),
          ),
        ],
      ),
    );
  }

  Widget _card(AppPal p, NextLecture n, DateTime now, Offset? loc) {
    final l = n.lecture;
    final s = _status(n, now, loc);
    final accent = s.urgent ? _urgent : aquaFoam;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [cyberTeal, p.deep],
        ),
        border: Border.all(
          color: s.urgent ? _urgent.withAlpha(150) : aquaFoam.withAlpha(p.dark ? 55 : 28),
        ),
        boxShadow: [
          BoxShadow(
            color: p.dark ? Colors.black.withAlpha(110) : cyberTeal.withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: aquaFoam.withAlpha(200)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _label(n),
                  style: TextStyle(
                    color: aquaFoam.withAlpha(210),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: aquaFoam.withAlpha(28),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${fmtTime(l.startMin)} - ${fmtTime(l.endMin)}',
                  style: const TextStyle(
                    color: aquaFoam,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.course,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.meeting_room_outlined, size: 16, color: aquaFoam.withAlpha(180)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: aquaFoam.withAlpha(190), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withAlpha(s.urgent ? 36 : 22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(s.icon, size: 20, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.text,
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loc == null && n.dayOffset == 0 && !n.ongoing) ...[
            const SizedBox(height: 6),
            Text(
              'حدد موقعك على الخريطة عشان يطلع وقت المشي أدق',
              style: TextStyle(color: aquaFoam.withAlpha(140), fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _navigate(l),
                  icon: const Icon(Icons.navigation_rounded, size: 20),
                  label: const Text(
                    'وصّلني',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: aquaFoam,
                    foregroundColor: cyberTeal,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onOpenSchedule,
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('جدولي'),
                style: TextButton.styleFrom(foregroundColor: aquaFoam),
              ),
            ],
          ),
        ],
      ),
    );
  }
}