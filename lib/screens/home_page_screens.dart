import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'map_viewer_screen.dart';
import 'colleges_screen.dart';
import 'favourite_screen.dart';
import 'account_screen.dart';

const Color cyberTeal = Color(0xFF03303B);
const Color aquaFoam = Color(0xFF96FCDF);

/// حالة الثيم العامة (تُستخدم في main.dart)
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

/// لوحة الألوان (كلها مشتقة من Cyber Teal و Aqua Foam)
/// كل لون إله قيمة للوضع الفاتح وقيمة للوضع الداكن، وبتتغير مع زر التبديل.
class _Pal {
  final bool dark;
  const _Pal(this.dark);

  // الخلفيات والكروت
  Color get bg => dark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get surface => dark ? const Color(0xFF042A33) : Colors.white;
  Color get actionBg => dark ? const Color(0xFF053844) : const Color(0xFFE9FFF9);
  Color get mapBox => dark ? const Color(0xFF053844) : aquaFoam.withAlpha(90);
  Color get border => dark ? const Color(0xFF0B5566) : aquaFoam;

  // النصوص
  Color get title => dark ? aquaFoam : cyberTeal;
  Color get sub => dark ? aquaFoam.withAlpha(180) : const Color(0xFF2A7F85);

  // الأيقونات الدائرية (الأفاتار)
  Color get avatarBg => dark ? aquaFoam : cyberTeal;
  Color get avatarFg => dark ? cyberTeal : aquaFoam;

  // كرت الترحيب
  List<Color> get welcome => dark
      ? [cyberTeal, const Color(0xFF05505F)]
      : [aquaFoam.withAlpha(120), aquaFoam];

  // شريط التنقل السفلي
  Color get bar => dark ? const Color(0xFF021F26) : cyberTeal;

  // الرسائل (SnackBar)
  Color get snackBg => dark ? aquaFoam : cyberTeal;
  Color get snackFg => dark ? cyberTeal : aquaFoam;
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  // الترتيب المنطقي: 0 الرئيسية، 1 الخريطة، 2 المفضلة، 3 حسابي
  int selectedIndex = 0;

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, 'الرئيسية'),
    _NavItem(Icons.map_rounded, 'الخريطة'),
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

  // فتح شاشة الخريطة المكبّرة
  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapViewerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ألوان تتغير حسب الوضع (من مكان واحد: _Pal)
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

    // شريط الحالة وشريط النظام السفلي بيتبعوا الوضع (أيقونات فاتحة/غامقة)
    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
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
          // 0 الرئيسية (والخريطة) • 1 المفضلة • 2 حسابي
          index: selectedIndex == 3 ? 2 : (selectedIndex == 2 ? 1 : 0),
          sizing: StackFit.expand,
          children: [
            SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: avatarBg,
                    child:
                        Icon(Icons.location_on, color: avatarFg, size: 32),
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
                  // زر تبديل الوضع
                  IconButton(
                    tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                    onPressed: toggleTheme,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
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
                    onPressed: () => showMessage('لا توجد إشعارات جديدة'),
                    icon: Icon(Icons.notifications_none,
                        color: title, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Welcome card
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
                      style: TextStyle(fontSize: 17, color: title),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search field
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
                    borderSide: BorderSide(color: title, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // mutah map card
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
                        Icon(Icons.map_outlined, color: title, size: 28),
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

                    // صورة الخريطة (بتفتح الخريطة المكبّرة عند الضغط)
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
                              errorBuilder: (_, __, ___) => Container(
                                color: mapBox,
                                alignment: Alignment.center,
                                child: Icon(Icons.map_outlined,
                                    size: 65, color: title),
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

              // Quick actions
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
                      () => showMessage('اختر وجهتك'),
                      actionBg,
                      border,
                      avatarBg,
                      avatarFg,
                      title,
                      sub),
                  _actionCard(
                      Icons.apartment,
                      'الكليات',
                      'تصفح كليات الجامعة',
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CollegesScreen()),
                          ),
                      actionBg,
                      border,
                      avatarBg,
                      avatarFg,
                      title,
                      sub),
                  _actionCard(
                      Icons.bookmark_border,
                      'المفضلة',
                      'أماكنك المحفوظة',
                      () => _goToTab(2),
                      actionBg,
                      border,
                      avatarBg,
                      avatarFg,
                      title,
                      sub),
                  _actionCard(
                      Icons.person_outline,
                      'حسابي',
                      'إعدادات المستخدم',
                      () => _goToTab(3),
                      actionBg,
                      border,
                      avatarBg,
                      avatarFg,
                      title,
                      sub),
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
            // تاب المفضلة (الـ nav bar بيضل ظاهر)
            // بنبنيه بس لما يكون مفتوح عشان أنيميشن الدخول يشتغل كل مرة
            selectedIndex == 2
                ? const FavoritesScreen(embedded: true)
                : const SizedBox.shrink(),
            // تاب حسابي (الـ nav bar بيضل ظاهر)
            selectedIndex == 3
                ? AccountScreen(
                    embedded: true,
                    onOpenFavorites: () => _goToTab(2),
                  )
                : const SizedBox.shrink(),
          ],
        ),

        // ====================== Curved Bottom Navigation ======================
        bottomNavigationBar: _buildNavBar(bg),
      ),
      ),
    );
  }

  Widget _buildNavBar(Color pageBg) {
    final int last = _navItems.length - 1;
    final Color barColor = _Pal(isDark).bar;

    // الشريط بيشتغل LTR داخلياً، فبنعكس الترتيب عشان يطلع صح بالـ RTL
    // (الرئيسية عاليمين). index بالشريط = last - الترتيب المنطقي.
    final visualItems = List<Widget>.generate(_navItems.length, (v) {
      final logical = last - v;
      final item = _navItems[logical];
      final selected = logical == selectedIndex;

      // الأيقونة المختارة بتطلع جوا الدائرة الفاتحة، فبتكون غامقة وبدون كلمة
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
        backgroundColor: pageBg, // نفس خلفية الصفحة عشان الانحناءة تندمج
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
    setState(() => selectedIndex = logical);
    // 0 الرئيسية • 2 المفضلة • 3 حسابي: بيتبدّل التاب تلقائياً من selectedIndex
    // 1 الخريطة: بدون رسالة (الشريط اللي كان يطلع انشال)
  }

  /// بتنقل لتاب معيّن (الترتيب المنطقي: 0 الرئيسية، 1 الخريطة، 2 المفضلة، 3 حسابي)
  /// وبتحرّك الـ nav bar معاها.
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