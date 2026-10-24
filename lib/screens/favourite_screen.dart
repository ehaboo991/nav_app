import 'package:flutter/material.dart';
import 'college_data.dart';
import 'colleges_screen.dart';
import 'home_page_screens.dart' show themeNotifier;
import 'it_college_screen.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);
const Color _gold = Color(0xFFFFC83D);

const List<List<Color>> _grads = [
  [Color(0xFF03303B), Color(0xFF0A6475)],
  [Color(0xFF0A6475), Color(0xFF1FA39A)],
  [Color(0xFF05505F), Color(0xFF2A7F85)],
  [Color(0xFF042A33), Color(0xFF0B7F88)],
];

// ====================== مخزن المفضلة ======================
/// الكليات المفضلة (بنخزّن اسم الكلية العربي كمفتاح).
/// مشتركة بين شاشة الكليات وشاشة المفضلة.
/// ملاحظة: محفوظة بالذاكرة بس، بتروح لما يتسكّر التطبيق.
final ValueNotifier<Set<String>> favoritesNotifier =
    ValueNotifier<Set<String>>(<String>{});

/// بتضيف الكلية للمفضلة أو بتشيلها. بترجّع true إذا انضافت.
bool toggleFavorite(String name) {
  final next = Set<String>.of(favoritesNotifier.value);
  final added = next.add(name);
  if (!added) next.remove(name);
  favoritesNotifier.value = next; // Set جديد عشان الـ listeners يتحدّثوا
  return added;
}

// ====================== شاشة المفضلة ======================
/// شاشة المفضلة
/// - embedded: true  => معروضة جوا التاب (الـ nav bar بيضل ظاهر، وبدون زر رجوع)
/// - embedded: false => صفحة مستقلة (فيها زر رجوع)
class FavoritesScreen extends StatelessWidget {
  final bool embedded;
  const FavoritesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _FavoritesBody(embedded: embedded),
    );
  }
}

class _FavoritesBody extends StatefulWidget {
  final bool embedded;
  const _FavoritesBody({required this.embedded});

  @override
  State<_FavoritesBody> createState() => _FavoritesBodyState();
}

class _FavoritesBodyState extends State<_FavoritesBody> {
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

  void _toggleTheme() {
    themeNotifier.value = _isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void _openCollege(College c) {
    if (c.nameAr == 'كلية تكنولوجيا المعلومات') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ItCollegeDetailsPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${c.nameAr} • مبنى ${c.building}')),
        );
    }
  }

  void _remove(College c) {
    toggleFavorite(c.nameAr);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: _isDark ? _aquaFoam : _cyberTeal,
          content: Text(
            'أُزيلت ${c.nameAr} من المفضلة',
            style: TextStyle(color: _isDark ? _cyberTeal : _aquaFoam),
          ),
          action: SnackBarAction(
            label: 'تراجع',
            textColor: _isDark ? _cyberTeal : _aquaFoam,
            onPressed: () => toggleFavorite(c.nameAr),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: favoritesNotifier,
          builder: (context, favs, _) {
            // بنحافظ على ترتيب الكليات الأصلي
            final items = colleges.where((c) => favs.contains(c.nameAr)).toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  _buildEmpty(context)
                else ...[
                  _buildSummary(items.length),
                  const SizedBox(height: 16),
                  for (int i = 0; i < items.length; i++) ...[
                    _card(items[i], i),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        ),
      );

    // جوا التاب: بدون Scaffold عشان الـ nav bar بتاع الرئيسية يضل ظاهر
    return widget.embedded
        ? Material(color: _bg, child: content)
        : Scaffold(backgroundColor: _bg, body: content);
  }

  // ====================== الشريط العلوي ======================
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        if (!widget.embedded) ...[
          _glassBtn(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.arrow_back_ios_new, color: _title, size: 19),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            'المفضلة',
            style: TextStyle(
              color: _title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _glassBtn(
          onTap: _toggleTheme,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(
              _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(_isDark),
              color: _title,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassBtn({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: _isDark ? _aquaFoam.withAlpha(30) : _cyberTeal.withAlpha(16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(11), child: child),
      ),
    );
  }

  // ====================== الملخص ======================
  Widget _buildSummary(int count) {
    final colors = _isDark
        ? [const Color(0xFF021F26), const Color(0xFF05505F)]
        : [_cyberTeal, const Color(0xFF0A6475)];

    return Container(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _aquaFoam.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: _gold, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1 ? 'عندك كلية وحدة بالمفضلة' : 'عندك $count كليات بالمفضلة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== كرت الكلية ======================
  Widget _card(College c, int i) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(c.nameAr),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (i.clamp(0, 6)) * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 22 * (1 - v)), child: child),
      ),
      child: Container(
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
                      child: _visual(c, i),
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
                        Material(
                          color: _tileBg,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _remove(c),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.star_rounded,
                                  size: 22, color: _gold),
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_left_rounded, color: _sub),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _visual(College c, int i) {
    final g = _grads[i % _grads.length];
    final grad = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: g,
        ),
      ),
    );
    final photo = c.imagePath;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (photo != null)
          Image.asset(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => grad)
        else
          grad,
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(photo == null ? 28 : 60),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(90), width: 1.2),
            ),
            child: Icon(c.icon, size: 26, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ====================== ما في مفضلة ======================
  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: _tileBg, shape: BoxShape.circle),
            child: Icon(Icons.star_border_rounded, size: 52, color: _title),
          ),
          const SizedBox(height: 18),
          Text(
            'لسا ما ضفت أي كلية للمفضلة',
            style: TextStyle(
              color: _title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اضغط على النجمة ⭐ فوق أي كلية عشان تظهر هون',
            textAlign: TextAlign.center,
            style: TextStyle(color: _sub, fontSize: 13.5, height: 1.6),
          ),
          const SizedBox(height: 22),
          Material(
            color: _isDark ? _aquaFoam : _cyberTeal,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                final route =
                    MaterialPageRoute(builder: (_) => const CollegesScreen());
                // جوا التاب: push عشان ما نستبدل الرئيسية
                widget.embedded
                    ? Navigator.push(context, route)
                    : Navigator.pushReplacement(context, route);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تصفح الكليات',
                      style: TextStyle(
                        color: _isDark ? _cyberTeal : _aquaFoam,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: _isDark ? _cyberTeal : _aquaFoam,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}