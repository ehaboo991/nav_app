import 'package:flutter/material.dart';
import 'image_viewer.dart';
const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة كلية الطب (لا تنسى تضيفها في pubspec.yaml تحت assets).
const String _heroImage = 'image/medicine.jpeg';

class _Floor {
  final String name;
  final List<String> places;
  const _Floor(this.name, this.places);
}

/// بيانات الطوابق: كل طابق لحاله.
const List<_Floor> _floors = [
  _Floor('الطابق الأول', [
    'حمام الطلاب',
    'مخرج',
    'الأمن الجامعي',
    'قاعة تدريسية ط1',
    'قاعة تدريسية ط102',
    'كافتيريا',
    'مصلى الطلاب',
    'المدرج الأخضر',
    'المدرج الأزرق',
    'الصيدلية الافتراضية',
    'مراقب القاعات',
    'مكتبة الطلبة',
    'قاعة تدريسية ط105',
    'مدخل',
    'استراحة الطلبة',
    'قاعة تدريسية ط103',
  ]),
  _Floor('الطابق الثاني', [
    'أعضاء هيئة التدريس',
    'عمادة كلية الطب',
    'الديوان ونائب الديوان',
    'قاعة الدراسات العليا',
    'المدير الإداري',
    'مساعد العميد لشؤون الطلبة والامتحانات',
  ]),
  _Floor('الطابق الثالث', [
    'مختبر الكائنات الدقيقة والمناعة',
    'مختبر الباثولوجي',
    'مختبر فسيولوجيا',
    'مختبر علم الأمراض',
    'المختبر السريري لعلم وظائف الأعضاء والأدوية',
    'مختبر الكيمياء والأحياء الجزيئية',
    'مختبر الكيمياء الحيوية والأحياء الجزيئية',
    'مختبر الأحياء الدقيقة',
    'مصلى الطالبات',
  ]),
  _Floor('الطابق الرابع', [
    'أعضاء هيئة التدريس',
  ]),
];

/// اختيار أيقونة مناسبة حسب اسم المكان.
IconData _iconFor(String name) {
  if (name.contains('حمام')) return Icons.wc_rounded;
  if (name.contains('مخرج')) return Icons.exit_to_app_rounded;
  if (name.contains('مدخل')) return Icons.login_rounded;
  if (name.contains('الأمن')) return Icons.security_rounded;
  if (name.contains('كافتيريا')) return Icons.local_cafe_rounded;
  if (name.contains('مصلى')) return Icons.mosque_rounded;
  if (name.contains('مدرج')) return Icons.event_seat_rounded;
  if (name.contains('الصيدلية')) return Icons.local_pharmacy_rounded;
  if (name.contains('مراقب')) return Icons.visibility_rounded;
  if (name.contains('مكتبة')) return Icons.local_library_rounded;
  if (name.contains('استراحة')) return Icons.weekend_rounded;
  if (name.contains('مختبر')) return Icons.science_rounded;
  if (name.contains('عمادة')) return Icons.account_balance_rounded;
  if (name.contains('الديوان')) return Icons.assignment_rounded;
  if (name.contains('الدراسات العليا')) return Icons.school_rounded;
  if (name.contains('المدير') || name.contains('مساعد')) {
    return Icons.badge_rounded;
  }
  if (name.contains('أعضاء')) return Icons.groups_rounded;
  if (name.contains('قاعة')) return Icons.meeting_room_rounded;
  return Icons.place_rounded;
}

class MedicineCollegeDetailsPage extends StatefulWidget {
  const MedicineCollegeDetailsPage({super.key});

  @override
  State<MedicineCollegeDetailsPage> createState() =>
      _MedicineCollegeDetailsPageState();
}

class _MedicineCollegeDetailsPageState
    extends State<MedicineCollegeDetailsPage> {
  int _selected = 0;

  // ---------- الثيم ----------
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
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildFloorSelector()),
            SliverToBoxAdapter(child: _buildFloorTitle(floor)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              sliver: SliverList.separated(
                itemCount: floor.places.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _appear(
                  i,
                  _placeTile(floor.places[i], i + 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appear(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$_selected-$i'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (i.clamp(0, 8)) * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: c),
      ),
      child: child,
    );
  }

  // ====================== الهيدر (صورة الكلية) ======================
  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      height: 250,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _heroImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF03303B), Color(0xFF0A6475)],
                ),
              ),
            ),
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
                  'كلية الطب',
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
                    'Faculty of Medicine',
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
    );
  }

  // ====================== اختيار الطابق ======================
  Widget _buildFloorSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _floors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _floorChip(i),
        ),
      ),
    );
  }

  Widget _floorChip(int i) {
    final on = _selected == i;
    final fg = on ? (_isDark ? _cyberTeal : _aquaFoam) : _title;

    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? (_isDark ? _aquaFoam : _cyberTeal) : _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: on ? Colors.transparent : _border),
        ),
        child: Row(
          children: [
            Icon(Icons.layers_rounded, size: 17, color: fg),
            const SizedBox(width: 6),
            Text(
              _floors[i].name,
              style: TextStyle(
                color: fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorTitle(_Floor floor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
      child: Row(
        children: [
          Text(
            floor.name,
            style: TextStyle(
              color: _title,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _tileBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${floor.places.length} مكان',
              style: TextStyle(
                color: _title,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== كرت المكان ======================
  Widget _placeTile(String name, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(_iconFor(name), size: 22, color: _title),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: _title,
                fontSize: 14.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$index',
            style: TextStyle(
              color: _sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}