import 'package:flutter/material.dart';
import 'image_viewer.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صورة الكلية (ضيفها في pubspec.yaml تحت assets).
/// إذا الصورة مش موجودة بتظهر خلفية متدرجة.
const String _collegeImage = 'image/engineering.jpeg';

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
    _Place(Icons.weekend_rounded, 'استراحة طلبة'),
    _Place(Icons.meeting_room_rounded, 'قاعات',
        note: 'لفة وحدة', halls: ['2', '4', '6', '8', '10', '16', '17']),
    _Place(Icons.meeting_room_rounded, 'قاعات',
        halls: ['1', '3', '5', '7', '9', '10']),
    _Place(Icons.meeting_room_rounded, 'قاعات',
        halls: ['9', '11', '12', '13', '15']),
    _Place(Icons.laptop_mac_rounded, 'لاب حاسوب', note: 'مشترك مع ط2'),
    _Place(Icons.wc_rounded, 'حمامات طالبات', note: 'موجود حمامين'),
    _Place(Icons.wc_rounded, 'حمام طلاب'),
    _Place(Icons.exit_to_app_rounded, 'Exit', note: 'مخرج'),
  ]),
  _Floor('الطابق الثاني', Icons.looks_two_rounded, [
    _Place(Icons.menu_book_rounded, 'JEA Study Zone', note: 'منطقة دراسة'),
    _Place(Icons.electrical_services_rounded, 'قسم الهندسة الكهربائية'),
  ]),
  _Floor('الطابق الثالث', Icons.looks_3_rounded, [
    _Place(Icons.memory_rounded, 'قسم هندسة الحاسوب'),
    _Place(Icons.science_rounded, 'قسم الهندسة الكيميائية'),
    _Place(Icons.precision_manufacturing_rounded, 'قسم الهندسة الميكانيكية'),
    _Place(Icons.meeting_room_rounded, 'قاعات', halls: ['17', '18']),
    _Place(Icons.mosque_rounded, 'مصلى للبنات'),
    _Place(Icons.mosque_rounded, 'مصلى للذكور'),
  ]),
];

// ====================== الصفحة ======================
class EngineeringCollegeDetailsPage extends StatefulWidget {
  const EngineeringCollegeDetailsPage({super.key});

  @override
  State<EngineeringCollegeDetailsPage> createState() =>
      _EngineeringCollegeDetailsPageState();
}

class _EngineeringCollegeDetailsPageState
    extends State<EngineeringCollegeDetailsPage> {
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

  // ====================== فتح الصورة بملء الشاشة ======================
  void _openFullImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const _FullImagePage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الصورة (قابلة للضغط)
          GestureDetector(
            onTap: () => _openFullImage(context),
            child: Hero(
              tag: 'college_image',
              child: Image.asset(
                _collegeImage,
                fit: BoxFit.cover,
                errorBuilder: (_, error, __) {
                  debugPrint('Engineering college image error: $error');
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
            ),
          ),
          // تعتيم لتوضيح النص (IgnorePointer عشان الضغطة توصل للصورة)
          IgnorePointer(
            child: DecoratedBox(
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
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'كلية الهندسة',
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
                      'Faculty of Engineering',
                      style: TextStyle(
                        fontSize: 13,
                        color: _aquaFoam.withAlpha(220),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

// ====================== صفحة عرض الصورة كاملة ======================
class _FullImagePage extends StatelessWidget {
  const _FullImagePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: SizedBox.expand(
          child: Center(
            child: Hero(
              tag: 'college_image',
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.asset(
                  _collegeImage,
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
        ),
      ),
    );
  }
}