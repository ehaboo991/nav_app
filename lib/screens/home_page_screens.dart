import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'map_viewer_screen.dart';
import 'campus_map_screen.dart';
import 'colleges_screen.dart';
import 'favourite_screen.dart';
import 'account_screen.dart';
import 'start_navigation_screen.dart';
import 'nav_ai_screen.dart';

const Color cyberTeal = Color(0xFF03303B);
const Color aquaFoam = Color(0xFF96FCDF);

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

class _Pal {
  final bool dark;
  const _Pal(this.dark);

  Color get bg => dark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get surface => dark ? const Color(0xFF042A33) : Colors.white;
  Color get actionBg => dark ? const Color(0xFF053844) : const Color(0xFFE9FFF9);
  Color get mapBox => dark ? const Color(0xFF053844) : aquaFoam.withAlpha(90);
  Color get border => dark ? const Color(0xFF0B5566) : aquaFoam;

  Color get title => dark ? aquaFoam : cyberTeal;
  Color get sub => dark ? aquaFoam.withAlpha(180) : const Color(0xFF2A7F85);

  Color get avatarBg => dark ? aquaFoam : cyberTeal;
  Color get avatarFg => dark ? cyberTeal : aquaFoam;

  List<Color> get welcome => dark
      ? [cyberTeal, const Color(0xFF05505F)]
      : [aquaFoam.withAlpha(120), aquaFoam];

  Color get bar => dark ? const Color(0xFF021F26) : cyberTeal;
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

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  // 0 الرئيسية | 1 الخريطة | 2 NAV AI (بالنص) | 3 المفضلة | 4 حسابي
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

  // فتح شاشة الخريطة القديمة من بطاقة الخريطة في الصفحة الرئيسية
  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapViewerScreen(),
      ),
    );
  }

  void openNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StartNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(isDark);
    final Color bg = p.bg;
    final Color surface = p.surface;
    final Color title = p.title;
    final Color sub = p.sub;
    final Color avatarBg = p.avatarBg;
    final Color avatarFg = p.avatarFg;
    final Color mapBox = p.mapBox;
    final Color border = p.border;
    final Color actionBg = p.actionBg;

    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: p.bar,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bg,
          body: IndexedStack(
            // 0 رئيسية | 1 NAV AI | 2 مفضلة | 3 حسابي
            index: const {0: 0, 2: 1, 3: 2, 4: 3}[selectedIndex] ?? 0,
            sizing: StackFit.expand,
            children: [
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: avatarBg,
                          child: Icon(
                            Icons.location_on,
                            color: avatarFg,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mutah-Nav',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: title,
                                ),
                              ),
                              Text(
                                'Your Campus, Your Way',
                                style: TextStyle(color: sub),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                          onPressed: toggleTheme,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                RotationTransition(
                              turns: anim,
                              child: child,
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              key: ValueKey(isDark),
                              color: title,
                              size: 28,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              showMessage('لا توجد إشعارات جديدة'),
                          icon: Icon(
                            Icons.notifications_none,
                            color: title,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: p.welcome),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بعودتك 👋',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: title,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'وين حاب تروح اليوم؟',
                            style: TextStyle(
                              fontSize: 17,
                              color: title,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      style: TextStyle(color: title),
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
                        hintStyle: TextStyle(color: sub),
                        prefixIcon: Icon(Icons.search, color: title),
                        filled: true,
                        fillColor: surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: title,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                color: title,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'خريطة الجامعة',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: title,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: openMap,
                            child: Hero(
                              tag: 'Mutah_Map',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: SizedBox(
                                  height: 190,
                                  width: double.infinity,
                                  child: Image.asset(
                                    'image/Mutah_Map.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: mapBox,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.map_outlined,
                                        size: 65,
                                        color: title,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: openMap,
                              child: Text(
                                'استكشف الخريطة ←',
                                style: TextStyle(color: title),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'الوصول السريع',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: title,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        _actionCard(
                          Icons.navigation,
                          'ابدأ الملاحة',
                          'الوصول إلى وجهتك',
                          openNavigation,
                          actionBg,
                          border,
                          avatarBg,
                          avatarFg,
                          title,
                          sub,
                        ),
                        _actionCard(
                          Icons.apartment,
                          'الكليات',
                          'تصفح كليات الجامعة',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CollegesScreen(),
                            ),
                          ),
                          actionBg,
                          border,
                          avatarBg,
                          avatarFg,
                          title,
                          sub,
                        ),
                        _actionCard(
                          Icons.bookmark_border,
                          'المفضلة',
                          'أماكنك المحفوظة',
                          () => _goToTab(3),
                          actionBg,
                          border,
                          avatarBg,
                          avatarFg,
                          title,
                          sub,
                        ),
                        _actionCard(
                          Icons.person_outline,
                          'حسابي',
                          'إعدادات المستخدم',
                          () => _goToTab(4),
                          actionBg,
                          border,
                          avatarBg,
                          avatarFg,
                          title,
                          sub,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: Text(
                        'Mutah University',
                        style: TextStyle(
                          fontSize: 16,
                          color: sub,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // NAV AI: دايماً موجود بالـ IndexedStack عشان المحادثة ما تنمسح
              const NavAiScreen(embedded: true),
              selectedIndex == 3
                  ? const FavoritesScreen(embedded: true)
                  : const SizedBox.shrink(),
              selectedIndex == 4
                  ? AccountScreen(
                      embedded: true,
                      onOpenFavorites: () => _goToTab(3),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: _buildNavBar(bg),
        ),
      ),
    );
  }

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

  // الخريطة (1) بس بتفتح كصفحة مستقلة، وNAV AI (2) تاب عادي
  void _onNavTap(int visualIndex) {
    final int logical = (_navItems.length - 1) - visualIndex;

    if (logical == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CampusMapScreen()),
      );

      // نرجع الشريط للتاب اللي كان مفتوح قبل الخريطة
      _navKey.currentState
          ?.setPage((_navItems.length - 1) - selectedIndex);
      return;
    }

    setState(() => selectedIndex = logical);
  }

  void _goToTab(int logical) {
    _navKey.currentState?.setPage((_navItems.length - 1) - logical);
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color cardColor,
    Color borderColor,
    Color avatarBg,
    Color avatarFg,
    Color titleColor,
    Color subColor,
  ) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarBg,
                child: Icon(icon, color: avatarFg, size: 25),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: subColor, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}