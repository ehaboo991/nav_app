import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة الكلية (ضيفها في pubspec.yaml تحت assets).
/// إذا الصورة مش موجودة بتظهر خلفية متدرجة.
const String _collegeImage = 'image/it .png';

// ====================== نموذج البيانات ======================
enum _HallType { hall, lab, office, service, controlRoom }

extension on _HallType {
  IconData get icon {
    switch (this) {
      case _HallType.hall:
        return Icons.meeting_room_rounded;
      case _HallType.lab:
        return Icons.computer_rounded;
      case _HallType.office:
        return Icons.badge_rounded;
      case _HallType.service:
        return Icons.room_service_rounded;
      case _HallType.controlRoom:
        return Icons.settings_input_component_rounded;
    }
  }

  String get label {
    switch (this) {
      case _HallType.hall:
        return 'قاعة';
      case _HallType.lab:
        return 'مختبر';
      case _HallType.office:
        return 'مكاتب';
      case _HallType.service:
        return 'خدمات';
      case _HallType.controlRoom:
        return 'Control Room';
    }
  }
}

class _Hall {
  final String name;
  final _HallType type;
  final String? note;
  final IconData? icon; // اختياري: أيقونة خاصة بدل أيقونة النوع
  const _Hall(this.name, this.type, {this.note, this.icon});
}

class _Floor {
  final String name;
  final IconData icon;
  final String alt; // اسم بديل للبحث فقط
  final List<_Hall> halls;
  const _Floor(this.name, this.icon, this.halls, {this.alt = ''});
}

/// ⚠️ بيانات تجريبية: عدّلها حسب القاعات الفعلية بالكلية.
const List<_Floor> _floors = [
  _Floor('الطابق الأول', Icons.looks_one_rounded, alt: 'الارضي', [
    _Hall('it-smart 101', _HallType.hall),
    _Hall('it-smart 102', _HallType.hall),
    _Hall('it-smart 103', _HallType.hall),
    _Hall('it-smart 104', _HallType.hall),
  ]),
  _Floor('الطابق الثاني', Icons.looks_two_rounded, [
    _Hall('it-smart 201', _HallType.hall),
    _Hall('it-smart 202', _HallType.hall),
    _Hall('it-smart 203', _HallType.hall),
    _Hall('قاعة الدراسات العليا 1', _HallType.hall,
        icon: Icons.school_rounded),
    _Hall('مختبر العوامل البشرية', _HallType.lab,
        icon: Icons.accessibility_new_rounded),
    _Hall('مختبر هندسة النظم الصناعية', _HallType.lab,
        icon: Icons.precision_manufacturing_rounded),
    _Hall('System Control', _HallType.controlRoom),
  ]),
  _Floor('الطابق الثالث', Icons.looks_3_rounded, [
    _Hall('it-lab 01', _HallType.lab),
    _Hall('it-lab 02', _HallType.lab),
    _Hall('it-lab 03', _HallType.lab),
    _Hall('it-lab 04', _HallType.lab),
    _Hall('it-lab 05', _HallType.lab),
    _Hall('it-smart 01', _HallType.hall),
    _Hall('it-smart 02', _HallType.hall),
    _Hall('it-smart 03', _HallType.hall),
    _Hall('it-smart 04', _HallType.hall),
  ]),
  _Floor('الطابق الرابع', Icons.looks_4_rounded, [
    _Hall('مكتب عميد الكلية', _HallType.office,
        note: 'د. أحمد الحسنات', icon: Icons.account_balance_rounded),
    _Hall('مكاتب رؤساء الاقسام', _HallType.office,
        note: 'د. حمزة عيال سلمان (علم الحاسوب) - '
            'د. أسماء النوايسة (علم البيانات وهندسة البرمجيات)'),
    _Hall('مكاتب اعضاء هيئة التدريس', _HallType.office,
        icon: Icons.groups_rounded),
    _Hall('ديوان الكلية', _HallType.office, icon: Icons.assignment_rounded),
    _Hall('المصلى', _HallType.service, icon: Icons.mosque_rounded),
    _Hall('WC بجانب المصلى', _HallType.service, icon: Icons.wc_rounded),
    _Hall('مختبر الامن السيبراني', _HallType.lab,
        icon: Icons.security_rounded),
    _Hall('مركز أبحاث وتطوير الذكاء الاصطناعي', _HallType.lab,
        icon: Icons.psychology_rounded),
  ]),
];

// ====================== البحث عن القاعات ======================
/// نتيجة بحث عن قاعة (بتُستخدم من الصفحة الرئيسية)
class ItHallResult {
  final String name;
  final String typeLabel;
  final IconData icon;
  final String floorTitle;
  final int floorIndex;
  const ItHallResult({
    required this.name,
    required this.typeLabel,
    required this.icon,
    required this.floorTitle,
    required this.floorIndex,
  });
}

/// بتوحّد النص: حروف صغيرة، بدون مسافات أو شرطات، وتوحيد الهمزات والتاء المربوطة
String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[\s\-_]+'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي');

/// بتدوّر باسم القاعة أو رقمها أو نوعها أو اسم الطابق.
/// أمثلة: "101" ، "it-smart 203" ، "it lab" ، "مختبر" ، "الطابق الثالث"
List<ItHallResult> searchItHalls(String query) {
  final q = _norm(query);
  if (q.isEmpty) return const [];

  final out = <ItHallResult>[];
  for (int i = 0; i < _floors.length; i++) {
    final f = _floors[i];
    for (final h in f.halls) {
      if (_norm(h.name).contains(q) ||
          _norm(h.type.label).contains(q) ||
          _norm(f.name).contains(q) ||
          (f.alt.isNotEmpty && _norm(f.alt).contains(q))) {
        out.add(ItHallResult(
          name: h.name,
          typeLabel: h.type.label,
          icon: h.icon ?? h.type.icon,
          floorTitle: f.name,
          floorIndex: i,
        ));
      }
    }
  }
  return out;
}

/// يعرض الصورة كاملة على الشاشة، وبالضغط على أي مكان بترجع للصفحة.
void _showFullImage(BuildContext context, String assetPath) {
  showDialog(
    context: context,
    useRootNavigator: true, // يفتحها فوق كل الشاشة
    useSafeArea: false,
    barrierColor: Colors.black,
    builder: (ctx) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(ctx).pop(), // أي ضغطة ترجّعك
      child: SizedBox.expand(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_rounded,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    ),
  );
}

// ====================== الصفحة ======================
class ItCollegeDetailsPage extends StatefulWidget {
  /// الطابق اللي يتفتح تلقائياً (لما نيجي من نتيجة بحث)
  final int? initialFloor;

  /// اسم القاعة اللي بتنعمل لها تظليل
  final String? highlightHall;

  const ItCollegeDetailsPage({
    super.key,
    this.initialFloor,
    this.highlightHall,
  });

  @override
  State<ItCollegeDetailsPage> createState() => _ItCollegeDetailsPageState();
}

class _ItCollegeDetailsPageState extends State<ItCollegeDetailsPage> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = (widget.initialFloor ?? 0).clamp(0, _floors.length - 1);
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get _surface => _isDark ? const Color(0xFF042A33) : Colors.white;
  Color get _title => _isDark ? _aquaFoam : _cyberTeal;
  Color get _sub =>
      _isDark ? _aquaFoam.withAlpha(170) : const Color(0xFF2A7F85);
  Color get _border =>
      _isDark ? _aquaFoam.withAlpha(45) : _aquaFoam.withAlpha(150);
  Color get _tileBg =>
      _isDark ? _aquaFoam.withAlpha(28) : _aquaFoam.withAlpha(85);
  Color get _shadow => Colors.black.withAlpha(_isDark ? 80 : 22);
  Color get _accent => _isDark ? _aquaFoam : const Color(0xFF1FA39A);

  @override
  Widget build(BuildContext context) {
    final floor = _floors[_selected];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _floorSelector()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              sliver: SliverList.separated(
                itemCount: floor.halls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _appear(
                  '${_selected}_$i',
                  i,
                  _placeCard(floor.halls[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== الهيدر (صورة الكلية) ======================
  Widget _header(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      height: 250,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: GestureDetector(
        onTap: () => _showFullImage(context, _collegeImage),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _collegeImage,
              fit: BoxFit.cover,
              // الصورة طويلة وفيها سما كثير، فبنركّز على المبنى واللوحة
              alignment: const Alignment(0, 0.3),
              errorBuilder: (_, error, __) {
                debugPrint('IT college image error: $error');
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF03303B), Color(0xFF0A6475)],
                    ),
                  ),
                );
              },
            ),
            // تعتيم لتوضيح النص
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(60),
                    _cyberTeal.withAlpha(215),
                  ],
                ),
              ),
            ),
            // أيقونة تلمّح إن الصورة بتنفتح
            Positioned(
              top: top + 8,
              left: 12,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(70),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fullscreen_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            Positioned(
              top: top + 8,
              right: 12,
              child: Material(
                color: _aquaFoam.withAlpha(40),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.all(11),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: _aquaFoam, size: 20),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              left: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'كلية تكنولوجيا المعلومات',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      'Faculty of Information Technology',
                      style: TextStyle(
                        fontSize: 13,
                        color: _aquaFoam.withAlpha(220),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- اختيار الطابق ----------
  Widget _floorSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: List.generate(_floors.length, (i) {
          final on = _selected == i;
          final fg = on ? (_isDark ? _cyberTeal : _aquaFoam) : _title;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: i == _floors.length - 1 ? 0 : 8),
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: on ? (_isDark ? _aquaFoam : _cyberTeal) : _surface,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: on ? Colors.transparent : _border),
                  ),
                  child: Column(
                    children: [
                      Icon(_floors[i].icon, size: 22, color: fg),
                      const SizedBox(height: 4),
                      Text(
                        _floors[i].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fg,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------- أنيميشن ظهور ----------
  Widget _appear(String key, int i, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(key),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (i.clamp(0, 8)) * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: c),
      ),
      child: child,
    );
  }

  // ---------- كرت المكان ----------
  Widget _placeCard(_Hall h) {
    final highlighted = widget.highlightHall == h.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted ? _accent : _border,
          width: highlighted ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(h.icon ?? h.type.icon, color: _title, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  h.name,
                  style: TextStyle(
                    color: _title,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  h.note ?? h.type.label,
                  style: TextStyle(color: _sub, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}