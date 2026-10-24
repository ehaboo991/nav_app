import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة الكلية (ضيفها في pubspec.yaml تحت assets).
/// إذا الصورة مش موجودة بتظهر خلفية متدرجة مع أيقونة.
const String _collegeImage = 'image/it .png';

// ====================== باليت الألوان (فاتح / داكن) ======================
class _Palette {
  final Color bg, surface, bannerBg, title, sub, border, tileBg, hallBg;
  final Color accent, connector, glass, shadow;
  final List<Color> gradient;
  const _Palette({
    required this.bg,
    required this.surface,
    required this.bannerBg,
    required this.title,
    required this.sub,
    required this.border,
    required this.tileBg,
    required this.hallBg,
    required this.accent,
    required this.connector,
    required this.glass,
    required this.shadow,
    required this.gradient,
  });

  static final light = _Palette(
    bg: const Color(0xFFF2FFFB),
    surface: Colors.white,
    bannerBg: const Color(0xFFC9FFF0),
    title: _cyberTeal,
    sub: const Color(0xFF237379), // أغمق شوي لوضوح أحسن على الأبيض
    border: _aquaFoam.withAlpha(150),
    tileBg: _aquaFoam.withAlpha(85),
    hallBg: _aquaFoam.withAlpha(45),
    accent: const Color(0xFF1FA39A),
    connector: _cyberTeal.withAlpha(50),
    glass: _cyberTeal.withAlpha(16),
    shadow: Colors.black.withAlpha(22),
    gradient: const [_cyberTeal, Color(0xFF0A6475)],
  );

  static final dark = _Palette(
    bg: const Color(0xFF01181E),
    surface: const Color(0xFF042A33),
    bannerBg: const Color(0xFF021F26),
    title: _aquaFoam,
    sub: _aquaFoam.withAlpha(170),
    border: _aquaFoam.withAlpha(45),
    tileBg: _aquaFoam.withAlpha(28),
    hallBg: _aquaFoam.withAlpha(14),
    accent: _aquaFoam,
    connector: _aquaFoam.withAlpha(70),
    glass: _aquaFoam.withAlpha(30),
    shadow: Colors.black.withAlpha(80),
    gradient: const [Color(0xFF021F26), Color(0xFF05505F)],
  );
}

enum _HallType { hall, lab, office, service }

extension on _HallType {
  IconData get icon {
    switch (this) {
      case _HallType.hall:
        return Icons.meeting_room_outlined;
      case _HallType.lab:
        return Icons.computer_rounded;
      case _HallType.office:
        return Icons.badge_outlined;
      case _HallType.service:
        return Icons.room_service_outlined;
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
    }
  }
}

class _Hall {
  final String name;
  final _HallType type;
  const _Hall(this.name, this.type);
}

class _Floor {
  final String number; // الرقم اللي بيظهر بالدائرة
  final String title;
  final List<_Hall> halls;
  const _Floor(this.number, this.title, this.halls);
}

/// ⚠️ بيانات تجريبية: عدّلها حسب القاعات الفعلية بالكلية.
/// لإضافة قاعة: _Hall('اسم القاعة', _HallType.hall)
/// لإضافة طابق: _Floor('رقم', 'اسم الطابق', [ ...القاعات ])
const List<_Floor> _floors = [
  _Floor('1', 'الطابق الاول (الارضي)', [
    _Hall('it-smart 101', _HallType.hall),
    _Hall('it-smart 102', _HallType.hall),
    _Hall('it-smart 103', _HallType.hall),
    _Hall('it-smart 104', _HallType.hall),
  ]),
  _Floor('2', 'الطابق الثاني', [
    _Hall('it-smart 201', _HallType.hall),
    _Hall('it-smart 202', _HallType.hall),
    _Hall('it-smart 203', _HallType.hall),
  ]),
  _Floor('3', 'الطابق الثالث', [
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
  _Floor('4', 'الطابق الرابع', [
    _Hall('مكتب عميد الكلية', _HallType.office),
    _Hall('مكاتب رؤساء الاقسام', _HallType.office),
    _Hall('مكاتب اعضاء هيئة التدريس', _HallType.office),
    _Hall('ديوان الكلية', _HallType.office),
    _Hall('المصلى', _HallType.service),
    _Hall('WC بجانب المصلى', _HallType.service),
    _Hall('مختبر الامن السيبراني', _HallType.lab),
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
          _norm(f.title).contains(q)) {
        out.add(ItHallResult(
          name: h.name,
          typeLabel: h.type.label,
          icon: h.type.icon,
          floorTitle: f.title,
          floorIndex: i,
        ));
      }
    }
  }
  return out;
}

/// إدارة الكلية
class _Person {
  final String role;
  final String name;
  final IconData icon;
  const _Person(this.role, this.name, this.icon);
}

const _Person _dean =
    _Person('عميد الكلية', 'د. أحمد الحسنات', Icons.person_rounded);

const List<_Person> _heads = [
  _Person('رئيس قسم علم الحاسوب', 'د. حمزة عيال سلمان', Icons.person_rounded),
  _Person('رئيسة قسم علم البيانات وهندسة البرمجيات', 'د. أسماء النوايسة',
      Icons.woman_rounded),
];

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
  final ScrollController _scroll = ScrollController();
  // الطوابق المفتوحة (الأرضي مفتوح افتراضياً، أو الطابق اللي جينا منه من البحث)
  late final Set<int> _open;

  @override
  void initState() {
    super.initState();
    _open = {widget.initialFloor ?? 0};
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // ---------- الثيم ----------
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  _Palette get _p => _isDark ? _Palette.dark : _Palette.light;

  Color get _bg => _p.bg;
  Color get _surface => _p.surface;
  Color get _title => _p.title;
  Color get _sub => _p.sub;
  Color get _border => _p.border;
  Color get _tileBg => _p.tileBg;
  Color get _shadow => _p.shadow;

  Widget _appear(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + i * 90),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 22 * (1 - v)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          color: _bg,
          child: SafeArea(
            child: ListView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 16),
                _appear(0, _buildBanner()),
                const SizedBox(height: 26),

                _appear(1, _sectionTitle('إدارة الكلية')),
                const SizedBox(height: 12),
                _appear(1, _buildLeadership()),

                const SizedBox(height: 26),
                _appear(2, _sectionTitle('الطوابق والقاعات')),
                const SizedBox(height: 12),
                for (int i = 0; i < _floors.length; i++)
                  _appear(2 + i, _floorCard(i, _floors[i])),

                const SizedBox(height: 16),
                _appear(4, _sectionTitle('معلومات تهمك')),
                const SizedBox(height: 12),
                _appear(
                  4,
                  _card(
                    child: Column(
                      children: [
                        _detailRow(
                          Icons.location_on_outlined,
                          'الجامعة',
                          'جامعة مؤتة - الكرك، الأردن',
                        ),
                        Divider(height: 26, color: _border),
                        _detailRow(
                          Icons.language_rounded,
                          'الموقع الرسمي',
                          'موقع كلية تكنولوجيا المعلومات',
                        ),
                        Divider(height: 26, color: _border),
                        _detailRow(
                          Icons.school_outlined,
                          'البرامج',
                          'البكالوريوس والدراسات العليا',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _appear(5, _buildCta()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== الشريط العلوي ======================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _glassBtn(
          icon: Icons.arrow_back_ios_new,
          size: 19,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'تفاصيل الكلية',
            style: TextStyle(
              color: _title,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassBtn({
    IconData? icon,
    double size = 22,
    Widget? child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _p.glass,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: child ?? Icon(icon, color: _title, size: size),
        ),
      ),
    );
  }

  // ====================== البانر (صورة الكلية) ======================
  Widget _buildBanner() {
    return Container(
      height: 250,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _p.bannerBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Image.asset(
        _collegeImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // الصورة طويلة وفيها سما كثير، فبنركّز على المبنى واللوحة
        alignment: const Alignment(0, 0.3),
        errorBuilder: (_, error, __) {
          // بيطبع سبب فشل تحميل الصورة بالـ Debug Console
          debugPrint('IT college image error: $error');
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF03303B), Color(0xFF1FA39A)],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white70,
              size: 70,
            ),
          );
        },
      ),
    );
  }

  // ====================== مكونات الأقسام ======================
  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _p.accent,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: TextStyle(
            color: _title,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  // ====================== إدارة الكلية ======================
  Widget _buildLeadership() {
    return Column(
      children: [
        _deanCard(_dean),
        // خط وصل بين العميد ورؤساء الأقسام
        Container(
          width: 2,
          height: 18,
          decoration: BoxDecoration(
            color: _p.connector,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        for (int i = 0; i < _heads.length; i++) ...[
          _headCard(_heads[i]),
          if (i != _heads.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _deanCard(_Person p) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _p.gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -22,
            bottom: -34,
            child: Icon(
              Icons.account_balance_outlined,
              size: 120,
              color: _aquaFoam.withAlpha(20),
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _aquaFoam,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withAlpha(120), width: 2),
                ),
                child: Icon(p.icon, size: 32, color: _cyberTeal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _aquaFoam.withAlpha(35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.role,
                        style: const TextStyle(
                          color: _aquaFoam,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headCard(_Person p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(p.icon, size: 26, color: _title),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.role,
                  style: TextStyle(
                    color: _sub,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floorCard(int index, _Floor f) {
    final open = _open.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() {
                  open ? _open.remove(index) : _open.add(index);
                }),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tileBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          f.number,
                          style: TextStyle(
                            color: _title,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.title,
                              style: TextStyle(
                                color: _title,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${f.halls.length} قاعات ومرافق',
                              style: TextStyle(color: _sub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _tileBg,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: _title,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: open
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
                        child: Column(
                          children: [
                            Divider(height: 1, color: _border),
                            const SizedBox(height: 10),
                            for (final h in f.halls) _hallRow(h),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hallRow(_Hall h) {
    final highlighted = widget.highlightHall == h.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? _p.tileBg : _p.hallBg,
        borderRadius: BorderRadius.circular(14),
        border: highlighted
            ? Border.all(color: _p.accent, width: 1.6)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(h.type.icon, size: 18, color: _title),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              h.name,
              style: TextStyle(
                color: _title,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _tileBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              h.type.label,
              style: TextStyle(
                color: _sub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
          child: Icon(icon, color: _title, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _title,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(color: _sub, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCta() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _p.gradient,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: -30,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 120,
              color: _aquaFoam.withAlpha(22),
            ),
          ),
          const SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: _aquaFoam, size: 32),
                SizedBox(height: 10),
                Text(
                  'مستقبلك يبدأ من هنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'تعرّف على طوابق الكلية وقاعاتها بسهولة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}