import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة الكلية (ضيفها في pubspec.yaml تحت assets).
/// إذا الصورة مش موجودة بتظهر خلفية متدرجة.
const String _collegeImage = 'image/buisness.jpeg';

// ====================== نموذج البيانات ======================
class _Place {
  final IconData icon;
  final String title;
  final String? note;
  final List<String> halls; // أرقام القاعات (اختياري)

  const _Place(this.icon, this.title, {this.note, this.halls = const []});
}

class _Floor {
  final String name;
  final IconData icon;
  final List<_Place> places;

  const _Floor(this.name, this.icon, this.places);
}

const List<_Floor> _floors = [
  _Floor('الطابق الأول', Icons.looks_one_rounded, [
    _Place(Icons.badge_rounded, 'مكاتب أعضاء هيئة التدريس'),
    _Place(Icons.insights_rounded, 'مكتب رئيس قسم تكنولوجيا وذكاء الأعمال'),
    _Place(Icons.meeting_room_rounded, 'قاعة الدكتور أيمن محمود المعايطة',
        halls: ['110']),
    _Place(Icons.computer_rounded, 'مختبر الأعمال (3)'),
    _Place(Icons.computer_rounded, 'مختبر الأعمال (2)'),
    _Place(Icons.computer_rounded, 'مختبر الأعمال (1)'),
    _Place(Icons.show_chart_rounded, 'غرفة محاكاة التداول الإلكتروني',
        note: 'بورصة عمان'),
    _Place(Icons.account_balance_rounded, 'مكتب عميد الكلية'),
    _Place(Icons.groups_rounded, 'قاعة اجتماعات الكلية'),
    _Place(Icons.person_rounded, 'مكتب نائب العميد'),
    _Place(Icons.assignment_rounded, 'ديوان الكلية'),
    _Place(Icons.weekend_rounded, 'استراحة'),
    _Place(Icons.event_seat_rounded, 'مدرجات الأعمال',
        note: 'مدرج 1 - مدرج 2 - مدرج 3'),
  ]),
  _Floor('الطابق الثاني', Icons.looks_two_rounded, [
    _Place(Icons.account_balance_wallet_rounded,
        'مكتب رئيس قسم اقتصاديات المال والأعمال'),
    _Place(Icons.apartment_rounded, 'مكتب رئيس قسم الإدارة العامة'),
    _Place(Icons.meeting_room_rounded, 'قاعات',
        note: 'من 207 إلى 218',
        halls: [
          '207',
          '208',
          '209',
          '210',
          '211',
          '212',
          '213',
          '214',
          '215',
          '216',
          '217',
          '218',
        ]),
    _Place(Icons.wc_rounded, 'حمام طالبات'),
  ]),
  _Floor('الطابق الثالث', Icons.looks_3_rounded, [
    _Place(Icons.business_center_rounded, 'مكتب رئيس قسم إدارة الأعمال'),
    _Place(Icons.campaign_rounded, 'مكتب رئيس قسم التسويق'),
    _Place(Icons.calculate_rounded, 'مكتب رئيس قسم المحاسبة'),
    _Place(Icons.account_balance_rounded,
        'مكتب رئيس قسم العلوم المالية والمصرفية'),
    _Place(Icons.meeting_room_rounded, 'قاعات',
        halls: ['310', '315', '316', '317', '319', '320']),
    _Place(Icons.wc_rounded, 'حمام طلاب'),
    _Place(Icons.wc_rounded, 'حمام طالبات'),
  ]),
];

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
class BusinessCollegeDetailsPage extends StatefulWidget {
  const BusinessCollegeDetailsPage({super.key});

  @override
  State<BusinessCollegeDetailsPage> createState() =>
      _BusinessCollegeDetailsPageState();
}

class _BusinessCollegeDetailsPageState
    extends State<BusinessCollegeDetailsPage> {
  int _selected = 0;

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
            SliverToBoxAdapter(child: _header(context)),
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
              errorBuilder: (_, error, __) {
                debugPrint('Business college image error: $error');
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
                    'كلية الأعمال',
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
                      'Faculty of Business',
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
                  end: i == _floors.length - 1 ? 0 : 10),
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
                          fontSize: 12.5,
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
          'هـ $n',
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