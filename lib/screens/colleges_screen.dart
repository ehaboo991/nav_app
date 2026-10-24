import 'package:flutter/material.dart';
import 'college_data.dart';
import 'favourite_screen.dart';
import 'it_college_screen.dart';


const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// صور الكليات (اختياري): اربط اسم الكلية بمسار الصورة.
/// إذا الكلية مش موجودة هون بتظهر خلفية متدرجة مع أيقونتها.
/// لا تنسى تضيف الصور في pubspec.yaml تحت assets.
const Map<String, String> _photos = {
  // 'كلية الهندسة': 'assets/colleges/engineering.jpg',
  // 'كلية الطب البشري': 'assets/colleges/medicine.jpg',
};

const List<List<Color>> _grads = [
  [Color(0xFF03303B), Color(0xFF0A6475)],
  [Color(0xFF0A6475), Color(0xFF1FA39A)],
  [Color(0xFF05505F), Color(0xFF2A7F85)],
  [Color(0xFF042A33), Color(0xFF0B7F88)],
];

enum _Sort { normal, name }

class CollegesScreen extends StatefulWidget {
  const CollegesScreen({super.key});

  @override
  State<CollegesScreen> createState() => _CollegesScreenState();
}

class _CollegesScreenState extends State<CollegesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _Sort _sort = _Sort.normal;
  bool _grid = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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

  List<College> get _filtered {
    final q = _query.trim().toLowerCase();
    var list = q.isEmpty
        ? List<College>.of(colleges)
        : colleges.where((c) {
            return c.nameAr.contains(q) ||
                c.nameEn.toLowerCase().contains(q) ||
                c.building.toString() == q;
          }).toList();

    switch (_sort) {
      case _Sort.name:
        list.sort((a, b) => a.nameAr.compareTo(b.nameAr));
        break;
      case _Sort.normal:
        break;
    }
    return list;
  }

  void _openCollege(College c) {
    if (c.nameAr == 'كلية تكنولوجيا المعلومات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ItCollegeDetailsPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${c.nameAr} • مبنى ${c.building}'),
        ),
      );
    }
  }

  void _toggleFav(College c) {
    final added = toggleFavorite(c.nameAr);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1300),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: _isDark ? _aquaFoam : _cyberTeal,
          content: Text(
            added
                ? 'أُضيفت ${c.nameAr} للمفضلة'
                : 'أُزيلت ${c.nameAr} من المفضلة',
            style: TextStyle(color: _isDark ? _cyberTeal : _aquaFoam),
          ),
        ),
      );
  }

  /// زر المفضلة. [onImage] = true لما يكون فوق صورة الكلية.
  Widget _favBtn(College c, {required bool onImage}) {
    const gold = Color(0xFFFFC83D);
    final bg = onImage ? Colors.black.withAlpha(95) : _tileBg;
    final off = onImage ? Colors.white : _title;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoritesNotifier,
      builder: (context, favs, _) {
        final on = favs.contains(c.nameAr);
        return Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _toggleFav(c),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  on ? Icons.star_rounded : Icons.star_border_rounded,
                  key: ValueKey(on),
                  size: 22,
                  color: on ? gold : off,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _appear(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$i$_query${_sort.name}$_grid'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (i.clamp(0, 8)) * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, list.length)),
            SliverToBoxAdapter(child: _buildStats(list.length)),
            SliverToBoxAdapter(child: _buildControls()),
            if (list.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
            else if (_grid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 232,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _appear(i, _gridCard(list[i], i)),
                    childCount: list.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _appear(i, _listCard(list[i], i)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ====================== الهيدر + البحث ======================
  Widget _buildHeader(BuildContext context, int count) {
    final top = MediaQuery.of(context).padding.top;
    final colors = _isDark
        ? [const Color(0xFF021F26), const Color(0xFF05505F)]
        : [_cyberTeal, const Color(0xFF0A6475)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: colors,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Stack(
              children: [
                // معلم الجامعة كعلامة مائية
                Positioned(
                  left: -30,
                  bottom: -26,
                  child: Icon(
                    Icons.account_balance_outlined,
                    size: 190,
                    color: _aquaFoam.withAlpha(20),
                  ),
                ),
                Positioned(
                  right: -50,
                  top: -60,
                  child: _circle(190, _aquaFoam.withAlpha(16)),
                ),
                Positioned(
                  left: 80,
                  top: 30,
                  child: _circle(36, _aquaFoam.withAlpha(22)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, top + 8, 16, 62),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _glassBtn(
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: _aquaFoam, size: 20),
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الكليات',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'استكشف كليات جامعة مؤتة',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _aquaFoam.withAlpha(215),
                                ),
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
          ),
          // البحث العائم
          Positioned(
            left: 20,
            right: 20,
            bottom: -26,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _shadow,
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _search,
                style: TextStyle(color: _title),
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الكلية أو رقم المبنى...',
                  hintStyle: TextStyle(color: _sub, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: _title),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close_rounded, color: _sub),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: _title, width: 1.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: _aquaFoam.withAlpha(30),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(11), child: child),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  // ====================== الإحصائيات ======================
  Widget _buildStats(int shown) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: SizedBox(
        height: 112, // ارتفاع ثابت لكل الكروت
        child: Row(
          children: [
            Expanded(
              child: _statTile(
                Icons.school_outlined,
                'كلية',
                animateTo: colleges.length,
              ),
            ),
            const SizedBox(width: 10),
            // كرت المبنى ثابت: نص مباشر بدون أنيميشن
            Expanded(
              child: _statTile(
                Icons.apartment_rounded,
                'مبنى',
                text: '20+',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                Icons.filter_list_rounded,
                'نتيجة',
                animateTo: shown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// إذا [animateTo] موجود الرقم بيعدّ بأنيميشن، وإلا بيعرض [text] ثابت.
  Widget _statTile(
    IconData icon,
    String label, {
    int? animateTo,
    String text = '',
  }) {
    final numberStyle = TextStyle(
      color: _title,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    );

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: _title),
          ),
          const SizedBox(height: 8),
          if (animateTo != null)
            TweenAnimationBuilder<int>(
              key: ValueKey('$label$animateTo'),
              tween: IntTween(begin: 0, end: animateTo),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text('$v', style: numberStyle),
            )
          else
            Directionality(
              textDirection: TextDirection.ltr, // عشان تظهر 20+ مظبوطة
              child: Text(text, style: numberStyle),
            ),
          Text(label, style: TextStyle(color: _sub, fontSize: 12)),
        ],
      ),
    );
  }

  // ====================== الترتيب + نمط العرض ======================
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('الكل', _Sort.normal, Icons.apps_rounded),
                  const SizedBox(width: 8),
                  _chip('أبجدي', _Sort.name, Icons.sort_by_alpha_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                _viewBtn(Icons.grid_view_rounded, true),
                _viewBtn(Icons.view_agenda_outlined, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _Sort s, IconData icon) {
    final on = _sort == s;
    final fg = on ? (_isDark ? _cyberTeal : _aquaFoam) : _title;
    return GestureDetector(
      onTap: () => setState(() => _sort = s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: on ? (_isDark ? _aquaFoam : _cyberTeal) : _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: on ? Colors.transparent : _border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewBtn(IconData icon, bool gridMode) {
    final on = _grid == gridMode;
    return GestureDetector(
      onTap: () => setState(() => _grid = gridMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: on ? _tileBg : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 19, color: on ? _title : _sub),
      ),
    );
  }

  // ====================== الجزء المرئي (صورة / تدرج) ======================
  Widget _visual(College c, int i, {required double iconSize}) {
    final g = _grads[i % _grads.length];
    final photo = c.imagePath ?? _photos[c.nameAr];

    return Stack(
      fit: StackFit.expand,
      children: [
        if (photo != null)
          Image.asset(
            photo,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _gradBox(g),
          )
        else
          _gradBox(g),
        // طبقة تعتيم خفيفة لتوضيح الأيقونة فوق الصورة
        if (photo != null)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(90)],
              ),
            ),
          ),
        if (photo == null) ...[
          Positioned(
            left: -iconSize * 0.25,
            bottom: -iconSize * 0.3,
            child: Icon(
              c.icon,
              size: iconSize * 2.2,
              color: _aquaFoam.withAlpha(30),
            ),
          ),
          Positioned(
            right: -14,
            top: -14,
            child: _circle(60, _aquaFoam.withAlpha(20)),
          ),
        ],
        Center(
          child: Container(
            width: iconSize + 22,
            height: iconSize + 22,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(photo == null ? 28 : 60),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(90), width: 1.2),
            ),
            child: Icon(c.icon, size: iconSize, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _gradBox(List<Color> g) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: g,
          ),
        ),
      );

  // ====================== كرت الشبكة ======================
  Widget _gridCard(College c, int i) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openCollege(c),
          child: Column(
            children: [
              SizedBox(
                height: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _visual(c, i, iconSize: 28),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _favBtn(c, onImage: true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nameAr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _title,
                          fontSize: 14.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            c.nameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _sub, fontSize: 11),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'تصفح تفاصيل الكلية',
                            style: TextStyle(
                              color: _title,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _tileBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back_rounded,
                                size: 16, color: _title),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== كرت القائمة ======================
  Widget _listCard(College c, int i) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openCollege(c),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: _visual(c, i, iconSize: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nameAr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _title,
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          c.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _sub, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تصفح تفاصيل الكلية',
                        style: TextStyle(
                          color: _title,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 92,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _favBtn(c, onImage: false),
                      Icon(Icons.chevron_left_rounded, color: _sub),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== لا نتائج ======================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: _sub),
          const SizedBox(height: 12),
          Text(
            'ما لقينا كلية بهالاسم',
            style: TextStyle(
              color: _title,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب كلمة ثانية أو رقم المبنى',
            style: TextStyle(color: _sub, fontSize: 13),
          ),
        ],
      ),
    );
  }
}