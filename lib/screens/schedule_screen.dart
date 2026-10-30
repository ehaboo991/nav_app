import 'package:flutter/material.dart';

import 'app_pallete.dart';
import 'college_data.dart';
import 'home_page_screens.dart' show cyberTeal, aquaFoam;
import 'map_viewer_screen.dart';
import 'schedule_data.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _day;

  @override
  void initState() {
    super.initState();
    final wd = DateTime.now().weekday;
    _day = kStudyDays.contains(wd) ? wd : DateTime.sunday;
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

  Future<void> _openEditor({Lecture? edit}) async {
    final day = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LectureEditorSheet(edit: edit, initialDay: _day),
    );
    if (day != null && mounted) setState(() => _day = day);
  }

  void _delete(Lecture l) {
    ScheduleStore.remove(l.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تم حذف ${l.course}'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () => ScheduleStore.add(l),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPal.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.bg,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(),
          backgroundColor: p.primaryBg,
          foregroundColor: p.onPrimary,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'إضافة محاضرة',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _header(p),
              Expanded(
                child: ValueListenableBuilder<List<Lecture>>(
                  valueListenable: ScheduleStore.lectures,
                  builder: (context, all, _) {
                    final today = ScheduleStore.forDay(_day);
                    return Column(
                      children: [
                        _dayChips(p, all),
                        Expanded(
                          child: today.isEmpty
                              ? _empty(p)
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 96),
                                  itemCount: today.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) => _lectureCard(
                                    p,
                                    today[i],
                                    i > 0 ? today[i - 1] : null,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppPal p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [cyberTeal, p.deep],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        border: Border.all(color: aquaFoam.withAlpha(p.dark ? 40 : 0)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_forward_rounded, color: aquaFoam),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'جدولي الدراسي',
                  style: TextStyle(
                    color: aquaFoam,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أضف محاضراتك مرة وحدة، والتطبيق بيذكّرك وبيوصّلك',
                  style: TextStyle(
                    color: aquaFoam.withAlpha(200),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayChips(AppPal p, List<Lecture> all) {
    final todayWd = DateTime.now().weekday;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          for (final d in kStudyDays)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _dayChip(
                  p,
                  d,
                  all.where((l) => l.weekday == d).length,
                  todayWd == d,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dayChip(AppPal p, int d, int count, bool isToday) {
    final sel = d == _day;
    final fg = sel ? p.onPrimary : p.title;
    return Material(
      color: sel ? p.primaryBg : p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _day = d),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? Colors.transparent : p.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  kDayNames[d]!,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count == 0 ? '—' : '$count',
                style: TextStyle(color: fg.withAlpha(170), fontSize: 11),
              ),
              const SizedBox(height: 4),
              isToday
                  ? Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                    )
                  : const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(AppPal p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, size: 60, color: p.sub),
            const SizedBox(height: 14),
            Text(
              'ما في محاضرات يوم ${kDayNames[_day]}',
              style: TextStyle(
                color: p.title,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اضغط "إضافة محاضرة" وحدد الأيام والوقت والقاعة',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.sub, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lectureCard(AppPal p, Lecture l, Lecture? prev) {
    String? warning;
    if (prev != null) {
      final gap = l.startMin - prev.endMin;
      final walk = Walk.between(prev.building, l.building);
      if (walk != null && walk > gap) {
        warning = 'الفرق بين المحاضرتين $gap د والمشي بياخد ~$walk د، اطلع بدري';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: p.actionBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        fmtTime(l.startMin),
                        style: TextStyle(
                          color: p.title,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Icon(Icons.arrow_downward_rounded,
                          size: 13, color: p.sub),
                      Text(
                        fmtTime(l.endMin),
                        style: TextStyle(color: p.sub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.course,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.meeting_room_outlined,
                              size: 16, color: p.sub),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              l.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: p.sub, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المدة: ${fmtDuration(l.endMin - l.startMin)}',
                        style: TextStyle(color: p.sub, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      tooltip: 'وصّلني',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _navigate(l),
                      icon: Icon(Icons.navigation_rounded, color: p.title),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'خيارات',
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_horiz_rounded, color: p.sub),
                      onSelected: (v) {
                        if (v == 'edit') _openEditor(edit: l);
                        if (v == 'del') _delete(l);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        PopupMenuItem(value: 'del', child: Text('حذف')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (warning != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: p.warn.withAlpha(30),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: p.warn),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        color: p.warn,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── نافذة إضافة / تعديل محاضرة ─────────────────────────

class _LectureEditorSheet extends StatefulWidget {
  final Lecture? edit;
  final int initialDay;

  const _LectureEditorSheet({this.edit, required this.initialDay});

  @override
  State<_LectureEditorSheet> createState() => _LectureEditorSheetState();
}

class _LectureEditorSheetState extends State<_LectureEditorSheet> {
  late final TextEditingController _course;
  late final TextEditingController _room;
  late final List<College> _options;
  College? _college;
  late Set<int> _days;
  late int _start;
  late int _end;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    _course = TextEditingController(text: e?.course ?? '');
    _room = TextEditingController(text: e?.room ?? '');
    _options = uniqueColleges();
    if (e != null) {
      for (final c in _options) {
        if (c.nameAr == e.buildingName) _college = c;
      }
    }
    _days = {e?.weekday ?? widget.initialDay};
    _start = e?.startMin ?? 9 * 60;
    _end = e?.endMin ?? 10 * 60;
  }

  @override
  void dispose() {
    _course.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final cur = isStart ? _start : _end;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60),
      builder: (c, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (t == null) return;
    setState(() {
      final m = t.hour * 60 + t.minute;
      if (isStart) {
        final dur = _end - _start;
        _start = m;
        if (_end <= _start) _end = _start + (dur > 0 ? dur : 60);
        if (_end > 1439) _end = 1439;
      } else {
        _end = m;
      }
      _error = null;
    });
  }

  void _fail(String m) => setState(() => _error = m);

  Future<void> _save() async {
    final course = _course.text.trim();
    final c = _college;
    if (course.isEmpty) return _fail('اكتب اسم المادة');
    if (c == null) return _fail('اختر الكلية / المبنى');
    if (_days.isEmpty) return _fail('اختر يوم واحد على الأقل');
    if (_end <= _start) return _fail('وقت النهاية لازم يكون بعد البداية');

    final sortedDays = kStudyDays.where(_days.contains).toList();
    final base = DateTime.now().microsecondsSinceEpoch;
    final list = <Lecture>[];
    for (var i = 0; i < sortedDays.length; i++) {
      final id = (i == 0 && widget.edit != null)
          ? widget.edit!.id
          : '${base}_$i';
      list.add(Lecture(
        id: id,
        course: course,
        room: _room.text.trim(),
        buildingName: c.nameAr,
        building: c.building,
        weekday: sortedDays[i],
        startMin: _start,
        endMin: _end,
      ));
    }

    for (final l in list) {
      final clash = ScheduleStore.conflict(l, ignoreId: widget.edit?.id);
      if (clash != null) {
        return _fail(
          'يتعارض مع ${clash.course} (${kDayNames[l.weekday]} ${fmtTime(clash.startMin)})',
        );
      }
    }

    if (widget.edit != null) {
      await ScheduleStore.replace(list.first);
      if (list.length > 1) await ScheduleStore.addAll(list.skip(1).toList());
    } else {
      await ScheduleStore.addAll(list);
    }
    if (mounted) Navigator.pop(context, list.first.weekday);
  }

  InputDecoration _dec(AppPal p, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: p.sub),
      prefixIcon: Icon(icon, color: p.sub),
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.title, width: 1.5),
      ),
    );
  }

  Widget _timeButton(AppPal p, String label, int value, bool isStart) {
    return OutlinedButton.icon(
      onPressed: () => _pickTime(isStart),
      icon: const Icon(Icons.schedule_rounded, size: 18),
      label: Text('$label ${fmtTime(value)}'),
      style: OutlinedButton.styleFrom(
        foregroundColor: p.title,
        backgroundColor: p.surface,
        side: BorderSide(color: p.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPal.of(context);
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final editing = widget.edit != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + inset),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: p.border),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.sub.withAlpha(90),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  editing ? 'تعديل المحاضرة' : 'إضافة محاضرة',
                  style: TextStyle(
                    color: p.title,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _course,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: p.title),
                  onChanged: (_) => setState(() => _error = null),
                  decoration: _dec(p, 'اسم المادة', Icons.menu_book_rounded),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<College>(
                      isExpanded: true,
                      value: _college,
                      dropdownColor: p.surface,
                      icon: Icon(Icons.expand_more_rounded, color: p.sub),
                      hint: Text(
                        'الكلية / المبنى',
                        style: TextStyle(color: p.sub),
                      ),
                      items: [
                        for (final c in _options)
                          DropdownMenuItem<College>(
                            value: c,
                            child: Text(
                              c.building == 0
                                  ? c.nameAr
                                  : '${c.nameAr} • مبنى ${c.building}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: p.title),
                            ),
                          ),
                      ],
                      onChanged: (c) => setState(() {
                        _college = c;
                        _error = null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _room,
                  style: TextStyle(color: p.title),
                  decoration: _dec(
                    p,
                    'القاعة (مثال: قاعة 204) — اختياري',
                    Icons.meeting_room_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'الأيام',
                  style: TextStyle(
                    color: p.title,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final d in kStudyDays)
                      FilterChip(
                        label: Text(kDayNames[d]!),
                        selected: _days.contains(d),
                        selectedColor: p.primaryBg,
                        backgroundColor: p.surface,
                        checkmarkColor: p.onPrimary,
                        side: BorderSide(color: p.border),
                        labelStyle: TextStyle(
                          color: _days.contains(d) ? p.onPrimary : p.title,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (s) => setState(() {
                          s ? _days.add(d) : _days.remove(d);
                          _error = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _timeButton(p, 'من', _start, true)),
                    const SizedBox(width: 10),
                    Expanded(child: _timeButton(p, 'إلى', _end, false)),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: p.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(editing ? 'حفظ التعديل' : 'حفظ المحاضرة'),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.primaryBg,
                      foregroundColor: p.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}