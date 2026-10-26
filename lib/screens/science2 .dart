import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة الكلية (ضيفها في pubspec.yaml تحت assets).
/// إذا الصورة مش موجودة بتظهر خلفية متدرجة مع أيقونة.
const String _collegeImage = 'image/science21.jpeg';

// ====================== نموذج البيانات ======================
class _Place {
  final IconData icon;
  final String title;
  final String? note;
  final List<String> halls; // أرقام القاعات / المختبرات (اختياري)

  const _Place(this.icon, this.title, {this.note, this.halls = const []});
}

class _Floor {
  final String name;
  final IconData icon;
  final List<_Place> places;

  const _Floor(this.name, this.icon, this.places);
}

const List<_Floor> _floors = [
  // ---------------- الطابق الأرضي (غرف 1xx) ----------------
  _Floor('الأرضي', Icons.home_work_rounded, [
    _Place(Icons.science_rounded, 'مختبر الكيمياء التحليلية'),
    _Place(Icons.science_rounded, 'مختبر NMR'),
    _Place(Icons.science_rounded, 'مختبرات الكيمياء العامة',
        halls: ['105', '106']),
    _Place(Icons.biotech_rounded, 'مختبرات الأحياء العامة',
        halls: ['105', '106']),
    _Place(Icons.biotech_rounded, 'مختبر أبحاث الأحياء 1'),
    _Place(Icons.biotech_rounded, 'مختبر أبحاث الأحياء 2'),
    _Place(Icons.precision_manufacturing_rounded, 'مختبر الطرق الآلي'),
    _Place(Icons.badge_rounded, 'مكاتب أعضاء هيئة التدريس'),
    _Place(Icons.supervisor_account_rounded, 'مكاتب المشرفين'),
    _Place(Icons.elevator_rounded, 'المصاعد والدرج'),
    _Place(Icons.exit_to_app_rounded, 'المخرج الجانبي', note: 'مخرج'),
  ]),

  // ---------------- الطابق الأول (غرف 2xx) ----------------
  _Floor('الأول', Icons.looks_one_rounded, [
    _Place(Icons.door_front_door_rounded, 'البوابة الرئيسية',
        note: 'المدخل الرئيسي للمبنى'),
    _Place(Icons.school_rounded, 'قاعات تدريس', halls: ['202', '204']),
    _Place(Icons.biotech_rounded, 'مختبر الكيمياء الحيوية'),
    _Place(Icons.pets_rounded, 'مختبر فسيولوجيا الحيوان'),
    _Place(Icons.eco_rounded, 'مختبر علم النبات'),
    _Place(Icons.biotech_rounded, 'مختبر الأحياء الدقيقة'),
    _Place(Icons.local_hospital_rounded, 'قسم العلوم الطبية والمخبرية'),
    _Place(Icons.account_balance_rounded, 'قسم العلوم الحياتية'),
    _Place(Icons.badge_rounded, 'مكاتب أعضاء هيئة التدريس'),
    _Place(Icons.supervisor_account_rounded, 'مكاتب المشرفين'),
    _Place(Icons.elevator_rounded, 'المصاعد والدرج'),
    _Place(Icons.exit_to_app_rounded, 'مخرج'),
  ]),

  // ---------------- الطابق الثاني (غرف 3xx) ----------------
  _Floor('الثاني', Icons.looks_two_rounded, [
    _Place(Icons.school_rounded, 'قاعات تدريس', halls: ['303', '305', '326']),
    _Place(Icons.menu_book_rounded, 'قاعة دراسات عليا', halls: ['329']),
    _Place(Icons.biotech_rounded, 'مختبرات أبحاث الأحياء',
        halls: ['3', '4', '5'], note: 'مختبر أبحاث الأحياء 3 و 4 و 5'),
    _Place(Icons.science_rounded, 'مختبر أبحاث الكيمياء غير العضوية'),
    _Place(Icons.science_rounded, 'مختبر أبحاث الكيمياء الفيزيائية'),
    _Place(Icons.science_rounded, 'مختبر الكيمياء الفيزيائية'),
    _Place(Icons.badge_rounded, 'مكاتب أعضاء هيئة التدريس'),
    _Place(Icons.supervisor_account_rounded, 'مكاتب المشرفين'),
    _Place(Icons.elevator_rounded, 'المصاعد والدرج'),
    _Place(Icons.exit_to_app_rounded, 'مخرج'),
  ]),

  // ---------------- الطابق الثالث (غرف 4xx) ----------------
  _Floor('الثالث', Icons.looks_3_rounded, [
    _Place(Icons.school_rounded, 'قاعات تدريس', halls: ['403', '406']),
    _Place(Icons.menu_book_rounded, 'قاعة دراسات عليا', halls: ['426']),
    _Place(Icons.account_balance_rounded, 'قسم الكيمياء'),
    _Place(Icons.science_rounded, 'مختبر الكيمياء العضوية'),
    _Place(Icons.science_rounded, 'مختبر الكيمياء غير العضوية'),
    _Place(Icons.science_rounded, 'مختبر أبحاث الكيمياء العضوية 1'),
    _Place(Icons.science_rounded, 'مختبر الكيمياء العضوية 2'),
    _Place(Icons.science_rounded, 'مختبر أبحاث الكيمياء غير العضوية'),
    _Place(Icons.bolt_rounded, 'مختبر أبحاث الكيمياء الكهربائية والتحليلية'),
    _Place(Icons.badge_rounded, 'مكاتب أعضاء هيئة التدريس'),
    _Place(Icons.supervisor_account_rounded, 'مكاتب المشرفين'),
    _Place(Icons.elevator_rounded, 'المصاعد والدرج'),
    _Place(Icons.exit_to_app_rounded, 'مخرج'),
  ]),
];

// ====================== الصفحة ======================
class ScienceCollege2DetailsPage extends StatefulWidget {
  const ScienceCollege2DetailsPage({super.key});

  @override
  State<ScienceCollege2DetailsPage> createState() =>
      _ScienceCollege2DetailsPageState();
}

class _ScienceCollege2DetailsPageState
    extends State<ScienceCollege2DetailsPage> {
  int _selected = 1; // يبدأ من الطابق الأول (طابق المدخل الرئيسي)

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
  Color get _bannerBg =>
      _isDark ? const Color(0xFF021F26) : const Color(0xFFC9FFF0);

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
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _floorSelector()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              sliver: SliverList.separated(
                itemCount: floor.places.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _appear(
                  '${_selected}_$i',
                  i,
                  _placeCard(floor.places[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- الهيدر ----------
  Widget _header(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final colors = _isDark
        ? [const Color(0xFF021F26), const Color(0xFF05505F)]
        : [_cyberTeal, const Color(0xFF0A6475)];

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: colors,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            bottom: -26,
            child: Icon(Icons.science_rounded,
                size: 190, color: _aquaFoam.withAlpha(20)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, top + 8, 16, 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: _aquaFoam.withAlpha(30),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'كلية العلوم 2',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'دليل الطوابق والمختبرات والخدمات',
                          style: TextStyle(
                              fontSize: 13, color: _aquaFoam.withAlpha(215)),
                        ),
                      ],
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

  // ---------- البانر (صورة الكلية) ----------
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 230,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _bannerBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _border, width: 1.2),
          boxShadow: [
            BoxShadow(
                color: _shadow, blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Image.asset(
          _collegeImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, error, __) {
            debugPrint('Science college image error: $error');
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
                Icons.science_rounded,
                color: Colors.white70,
                size: 70,
              ),
            );
          },
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
                        style: TextStyle(
                          color: fg,
                          fontSize: 12,
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
  Widget _placeCard(_Place p) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(p.icon, color: _title, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  p.title,
                  style: TextStyle(
                    color: _title,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (p.note != null) ...[
                  const SizedBox(height: 3),
                  Text(p.note!, style: TextStyle(color: _sub, fontSize: 12.5)),
                ],
                if (p.halls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: p.halls.map(_hallChip).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hallChip(String n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _tileBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          n,
          style: TextStyle(
            color: _title,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}