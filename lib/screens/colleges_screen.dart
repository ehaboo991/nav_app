import 'package:flutter/material.dart';
import 'college_data.dart';
import 'home_page_screens.dart' show themeNotifier;

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);
const Color _mapMaroon = Color(0xFF8A1538); // نفس لون دبابيس الخريطة

class CollegesScreen extends StatefulWidget {
  const CollegesScreen({super.key});

  @override
  State<CollegesScreen> createState() => _CollegesScreenState();
}

class _CollegesScreenState extends State<CollegesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

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

  List<College> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return colleges;
    return colleges.where((c) {
      return c.nameAr.contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.building.toString() == q;
    }).toList();
  }

  void _toggleTheme() {
    themeNotifier.value = _isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void _openCollege(College c) {
    // الخطوة 2: هون بنفتح شاشة تفاصيل الكلية
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: _isDark ? _aquaFoam : _cyberTeal,
        content: Text(
          '${c.nameAr} • مبنى ${c.building}',
          style: TextStyle(color: _isDark ? _cyberTeal : _aquaFoam),
        ),
      ),
    );
  }

  Widget _appear(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${child.key}$i$_query'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (i.clamp(0, 8)) * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: c),
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
        body: Stack(
          children: [
            // ---------- الخلفية المخصصة ----------
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  child: RepaintBoundary(
                    key: ValueKey(_isDark),
                    child: CustomPaint(
                      painter: _BgPainter(isDark: _isDark),
                    ),
                  ),
                ),
              ),
            ),
            // ---------- المحتوى ----------
            Column(
              children: [
                _buildHeader(context, list.length),
                const SizedBox(height: 40),
                Expanded(
                  child: list.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _appear(i, _collegeCard(list[i])),
                        ),
                ),
              ],
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

    return Stack(
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
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -40,
                top: -30,
                child: _circle(150, _aquaFoam.withAlpha(22)),
              ),
              Positioned(
                right: -25,
                bottom: -50,
                child: _circle(120, _aquaFoam.withAlpha(16)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, top + 8, 20, 52),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: _aquaFoam, size: 22),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الكليات',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count كلية • جامعة مؤتة',
                            style: TextStyle(
                              fontSize: 13,
                              color: _aquaFoam.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: _aquaFoam.withAlpha(30),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _toggleTheme,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                RotationTransition(turns: anim, child: child),
                            child: Icon(
                              _isDark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              key: ValueKey(_isDark),
                              color: _aquaFoam,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -26,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_isDark ? 90 : 35),
                  blurRadius: 20,
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
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: _title, width: 1.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  // ====================== كرت الكلية ======================
  Widget _collegeCard(College c) {
    return Material(
      color: _surface.withAlpha(_isDark ? 225 : 235),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openCollege(c),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              // أيقونة الكلية
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _tileBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(c.icon, size: 28, color: _title),
              ),
              const SizedBox(width: 14),

              // الأسماء
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nameAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _title,
                        fontSize: 17,
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
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // شارة رقم المبنى (نفس لون دبابيس الخريطة)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mapMaroon,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _mapMaroon.withAlpha(90),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${c.building}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مبنى',
                    style: TextStyle(color: _sub, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_left_rounded, color: _sub),
            ],
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

// ====================== رسّام الخلفية ======================
class _BgPainter extends CustomPainter {
  final bool isDark;
  const _BgPainter({required this.isDark});

  static const Color _teal = Color(0xFF03303B);
  static const Color _aqua = Color(0xFF96FCDF);
  static const Color _maroon = Color(0xFF8A1538);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1) الخلفية الأساسية (تدرج)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF01181E), Color(0xFF032B35), Color(0xFF01181E)]
              : [
                  const Color(0xFFF2FFFB),
                  _aqua.withAlpha(60),
                  const Color(0xFFF2FFFB),
                ],
        ).createShader(rect),
    );

    // 2) توهج دائري بلون Aqua Foam
    void glow(Offset c, double r, int alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [_aqua.withAlpha(alpha), _aqua.withAlpha(0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    glow(Offset(w * 0.05, h * 0.30), w * 0.7, isDark ? 40 : 90);
    glow(Offset(w * 0.95, h * 0.85), w * 0.8, isDark ? 32 : 80);

    // 3) شبكة نقاط (إحساس الخريطة)
    final dot = Paint()
      ..color = isDark ? _aqua.withAlpha(24) : _teal.withAlpha(20);
    const gap = 28.0;
    for (double x = gap / 2; x < w; x += gap) {
      for (double y = gap / 2; y < h; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, dot);
      }
    }

    // 4) حلقات رادار (موقعك)
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = isDark ? _aqua.withAlpha(26) : _teal.withAlpha(24);
    final rc = Offset(w * 0.92, h * 0.80);
    for (double r = 60; r <= 300; r += 60) {
      canvas.drawCircle(rc, r, ring);
    }

    // 5) مسار ملاحة متقطع ينتهي بدبوس
    final path = Path()
      ..moveTo(-20, h * 0.38)
      ..cubicTo(w * 0.30, h * 0.30, w * 0.40, h * 0.62, w * 0.70, h * 0.58)
      ..cubicTo(w * 0.85, h * 0.56, w * 0.90, h * 0.70, w * 0.92, h * 0.80);

    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = isDark ? _aqua.withAlpha(60) : _teal.withAlpha(50);

    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 9), dash);
        d += 18;
      }
    }

    // دبوس الوجهة
    canvas.drawCircle(rc, 11, Paint()..color = _maroon.withAlpha(50));
    canvas.drawCircle(rc, 5.5, Paint()..color = _maroon.withAlpha(190));
    canvas.drawCircle(
      rc,
      5.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withAlpha(isDark ? 160 : 230),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.isDark != isDark;
}