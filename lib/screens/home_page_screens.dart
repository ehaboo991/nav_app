import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'map_viewer_screen.dart';
import 'colleges_screen.dart';
import 'favourite_screen.dart';
import 'account_screen.dart';
import 'start_navigation_screen.dart';
import 'nav_ai_screen.dart';
import 'other_places_screen.dart';

// ╔═══════════════════════════════════════════════╗
// ║  اختار الباليت من هون:                        ║
// ║  0 = Cyber Teal + Aqua Foam (الأصلية)         ║
// ║  1 = Inkberry + Peach                         ║
// ║  2 = Blueberry + Cream Soda                   ║
// ║  3 = Quantum Blue + Ice Glass (الجديدة)       ║
// ╚═══════════════════════════════════════════════╝
const int kPalette = 0;

// Inkberry #1A0B2E | Peach #FFB7A5
// Blueberry #253B90 | Cream Soda #FEEFC8
// Quantum Blue #2950F6 | Ice Glass #DFF8FD
const Color cyberTeal = kPalette == 3
    ? Color(0xFF2950F6)
    : kPalette == 2
        ? Color(0xFF253B90)
        : kPalette == 1
            ? Color(0xFF1A0B2E)
            : Color(0xFF03303B);
const Color aquaFoam = kPalette == 3
    ? Color(0xFFDFF8FD)
    : kPalette == 2
        ? Color(0xFFFEEFC8)
        : kPalette == 1
            ? Color(0xFFFFB7A5)
            : Color(0xFF96FCDF);

// درجات مشتقة للتدرجات
const Color _deep2 = kPalette == 3
    ? Color(0xFF4A70FF)
    : kPalette == 2
        ? Color(0xFF3552B0)
        : kPalette == 1
            ? Color(0xFF3A1B63)
            : Color(0xFF0A5566);
const Color _accent2 = kPalette == 3
    ? Color(0xFFB3E4F2)
    : kPalette == 2
        ? Color(0xFFF5DB9A)
        : kPalette == 1
            ? Color(0xFFFF9C86)
            : Color(0xFF5FD9BC);

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

/// لوحة الألوان
class _Pal {
  final bool dark;
  const _Pal(this.dark);

  // teal / ink / blueberry / quantum
  static Color _pick(Color teal, Color ink, Color blue, Color quantum) =>
      kPalette == 3
          ? quantum
          : kPalette == 2
              ? blue
              : (kPalette == 1 ? ink : teal);

  Color get bg => dark
      ? _pick(const Color(0xFF01181E), const Color(0xFF0F0719),
          const Color(0xFF0B1230), const Color(0xFF060B24))
      : _pick(const Color(0xFFF2FFFB), const Color(0xFFFFF6F3),
          const Color(0xFFFFF9EA), const Color(0xFFF3FCFF));
  Color get surface => dark
      ? _pick(const Color(0xFF042A33), const Color(0xFF241240),
          const Color(0xFF142048), const Color(0xFF0E1740))
      : Colors.white;
  Color get actionBg => dark
      ? _pick(const Color(0xFF053844), const Color(0xFF2E1850),
          const Color(0xFF1B2A5E), const Color(0xFF142158))
      : _pick(const Color(0xFFE3FBF4), const Color(0xFFFFE7E0),
          const Color(0xFFFFF0CC), const Color(0xFFE4F7FD));
  Color get border => dark
      ? _pick(const Color(0xFF0B5566), const Color(0xFF45266E),
          const Color(0xFF2C3F85), const Color(0xFF22379A))
      : _pick(const Color(0xFFCFF7EA), const Color(0xFFFFD3C7),
          const Color(0xFFF5E1AA), const Color(0xFFC4EBF7));

  Color get title => dark ? aquaFoam : cyberTeal;
  Color get sub => dark
      ? aquaFoam.withAlpha(170)
      : _pick(const Color(0xFF2A7F85), const Color(0xFF7A5A8C),
          const Color(0xFF5B6BA8), const Color(0xFF5772C9));

  // الزر الرئيسي (ابدأ الملاحة): معكوس حسب الوضع
  Color get primaryBg => dark ? aquaFoam : cyberTeal;
  Color get primaryFg => dark ? cyberTeal : aquaFoam;

  Color get shadow =>
      dark ? Colors.black.withAlpha(110) : cyberTeal.withAlpha(45);

  Color get bar => dark
      ? _pick(const Color(0xFF021F26), const Color(0xFF120824),
          const Color(0xFF0E1740), const Color(0xFF0A1236))
      : cyberTeal;
  Color get snackBg => dark ? aquaFoam : cyberTeal;
  Color get snackFg => dark ? cyberTeal : aquaFoam;
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int selectedIndex = 0;

  /// بعد أول فتح لـ NAV AI بنخلي الشاشة محفوظة عشان ما تضيع المحادثة
  bool _aiOpened = false;

  /// نفس الفكرة للخريطة
  bool _mapOpened = false;

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  final TextEditingController searchController = TextEditingController();

  // 0 الرئيسية | 1 الخريطة | 2 NAV AI (بالمنتصف) | 3 المفضلة | 4 حسابي
  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, 'الرئيسية'),
    _NavItem(Icons.map_rounded, 'الخريطة'),
    _NavItem(Icons.auto_awesome, 'NAV AI'),
    _NavItem(Icons.star_rounded, 'المفضلة'),
    _NavItem(Icons.person_rounded, 'حسابي'),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  void toggleTheme() {
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: _Pal(isDark).snackFg),
        ),
        backgroundColor: _Pal(isDark).snackBg,
      ),
    );
  }

  void openMap() => _goToTab(1);

  void openNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StartNavigationScreen()),
    );
  }

  void openOtherPlaces() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OtherPlacesScreen()),
    );
  }

  void openColleges() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CollegesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(isDark);

    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: p.bar,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    final scaffold = Scaffold(
      backgroundColor: p.bg,
      body: IndexedStack(
        // children: 0 رئيسية | 1 مفضلة | 2 حسابي | 3 NAV AI | 4 الخريطة
        index: const {0: 0, 3: 1, 4: 2, 2: 3, 1: 4}[selectedIndex] ?? 0,
        sizing: StackFit.expand,
        children: [
          _buildHome(p),
          selectedIndex == 3
              ? const FavoritesScreen(embedded: true)
              : const SizedBox.shrink(),
          selectedIndex == 4
              ? AccountScreen(
                  embedded: true,
                  onOpenFavorites: () => _goToTab(3),
                )
              : const SizedBox.shrink(),
          _aiOpened
              ? const NavAiScreen(embedded: true)
              : const SizedBox.shrink(),
          _mapOpened ? const MapViewerScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(p.bg),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: scaffold,
      ),
    );
  }

  // ───────────────────────── الصفحة الرئيسية ─────────────────────────

  Widget _buildHome(_Pal p) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _buildHeader(p),
          const SizedBox(height: 18),
          _buildHero(p),
          const SizedBox(height: 26),
          Text(
            'الوصول السريع',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: p.title,
            ),
          ),
          const SizedBox(height: 14),
          _buildPrimaryAction(p),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _smallTile(
                  p,
                  Icons.apartment_rounded,
                  'الكليات',
                  'تصفح كليات الجامعة',
                  openColleges,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smallTile(
                  p,
                  Icons.place_outlined,
                  'أماكن أخرى',
                  'مكتبة، مجمعات، صالات',
                  openOtherPlaces,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smallTile(
                  p,
                  Icons.person_outline_rounded,
                  'حسابي',
                  'إعدادات المستخدم',
                  () => _goToTab(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Mutah University',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.6,
                color: p.sub,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_Pal p) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: p.dark
                  ? [aquaFoam, _accent2]
                  : [cyberTeal, _deep2],
            ),
            boxShadow: [
              BoxShadow(
                color: p.shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: p.dark ? cyberTeal : aquaFoam,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          // FittedBox عشان العنوان يصغّر شوي على الشاشات الضيقة وما يصير overflow
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mutah-Nav',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: p.title,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your Campus, Your Way',
                  style: TextStyle(color: p.sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
        _roundIconButton(
          p,
          tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
          onPressed: toggleTheme,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
              color: p.title,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _roundIconButton(
          p,
          tooltip: 'الإشعارات',
          onPressed: () => showMessage('لا توجد إشعارات جديدة'),
          child: Icon(Icons.notifications_none_rounded,
              color: p.title, size: 22),
        ),
      ],
    );
  }

  Widget _roundIconButton(
    _Pal p, {
    required String tooltip,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: p.surface,
        shape: CircleBorder(side: BorderSide(color: p.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(width: 42, height: 42, child: Center(child: child)),
        ),
      ),
    );
  }

  /// العنصر الأبرز بالصفحة: الخريطة كواجهة رئيسية + الترحيب + البحث
  Widget _buildHero(_Pal p) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
      ),
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: p.shadow,
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // الخلفية: صورة الخريطة + تدرج لوني — الضغط عليها يفتح الخريطة
              GestureDetector(
                onTap: openMap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'image/Mutah_Map.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cyberTeal, _deep2],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.map_outlined,
                          size: 80,
                          color: aquaFoam.withAlpha(90),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cyberTeal.withAlpha(235),
                            cyberTeal.withAlpha(120),
                            cyberTeal.withAlpha(215),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // الترحيب + زر فتح الخريطة
              PositionedDirectional(
                top: 22,
                start: 22,
                end: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بعودتك 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: aquaFoam,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'وين حاب تروح اليوم؟',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: openMap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: aquaFoam.withAlpha(110)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_rounded,
                                size: 16, color: aquaFoam),
                            SizedBox(width: 6),
                            Text(
                              'الخريطة',
                              style: TextStyle(
                                color: aquaFoam,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // شريط البحث العائم
              PositionedDirectional(
                bottom: 18,
                start: 16,
                end: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: p.title, fontWeight: FontWeight.w600),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        showMessage('بحث عن: $value');
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قاعة أو مبنى...',
                      hintStyle: TextStyle(color: p.sub, fontSize: 14.5),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: p.title, size: 24),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: p.primaryBg,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              final v = searchController.text.trim();
                              if (v.isNotEmpty) showMessage('بحث عن: $v');
                            },
                            child: Icon(Icons.tune_rounded,
                                color: p.primaryFg, size: 20),
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "ابدأ الملاحة": أهم إجراء بالتطبيق، لذلك بحجم أكبر ولون مختلف
  Widget _buildPrimaryAction(_Pal p) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: p.dark
              ? [aquaFoam, _accent2]
              : [cyberTeal, _deep2],
        ),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: openNavigation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: p.primaryFg.withAlpha(p.dark ? 30 : 38),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.navigation_rounded,
                      color: p.primaryFg, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ابدأ الملاحة',
                        style: TextStyle(
                          color: p.primaryFg,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'الوصول إلى وجهتك',
                        style: TextStyle(
                          color: p.primaryFg.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.primaryFg,
                    shape: BoxShape.circle,
                  ),
                  // RTL: السهم للأمام = يسار
                  child: Icon(Icons.arrow_back_rounded,
                      color: p.primaryBg, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallTile(
    _Pal p,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.actionBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: p.title, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                // ارتفاع ثابت يكفي سطرين، عشان العناوين تتساوى بكل البطاقات
                SizedBox(
                  height: 30,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.sub,
                        fontSize: 11,
                        height: 1.3,
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

  // ───────────────────────── الشريط السفلي (بدون تغيير بالوظيفة) ─────────────────────────

  Widget _buildNavBar(Color pageBg) {
    final int last = _navItems.length - 1;
    final Color barColor = _Pal(isDark).bar;

    final visualItems = List<Widget>.generate(_navItems.length, (v) {
      final logical = last - v;
      final item = _navItems[logical];
      final selected = logical == selectedIndex;

      if (selected) {
        return Icon(item.icon, size: 28, color: cyberTeal);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 26, color: aquaFoam),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10.5,
              color: aquaFoam.withAlpha(220),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    });

    return Directionality(
      textDirection: TextDirection.ltr,
      child: CurvedNavigationBar(
        key: _navKey,
        index: last - selectedIndex,
        height: 68,
        items: visualItems,
        color: barColor,
        buttonBackgroundColor: aquaFoam,
        backgroundColor: pageBg,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 500),
        letIndexChange: _letIndexChange,
        onTap: _onNavTap,
      ),
    );
  }

  bool _letIndexChange(int index) => true;

  void _onNavTap(int visualIndex) {
    final int logical = (_navItems.length - 1) - visualIndex;

    setState(() {
      selectedIndex = logical;
      if (logical == 2) _aiOpened = true;
      if (logical == 1) _mapOpened = true;
    });
  }

  void _goToTab(int logical) {
    _navKey.currentState?.setPage((_navItems.length - 1) - logical);
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}