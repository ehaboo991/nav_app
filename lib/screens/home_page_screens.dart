import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'map_viewer_screen.dart';
import 'colleges_screen.dart';
import 'favourite_screen.dart';
import 'it_college_screen.dart';
import 'account_screen.dart';
import 'navigation_screen.dart'; // <-- جديد: شاشة الملاحة


const Color cyberTeal = Color(0xFF03303B);
const Color aquaFoam = Color(0xFF96FCDF);

/// حالة الثيم العامة (تُستخدم في main.dart)
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.light);

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  // الترتيب المنطقي: 0 الرئيسية، 1 الخريطة، 2 المفضلة، 3 حسابي
  int selectedIndex = 0;

  static const int _favIndex = 2;
  static const int _accountIndex = 3;

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

  /// بتخفي كيبورد النظام لو طلع لأي سبب
  void _hideSystemKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isDark ? cyberTeal : aquaFoam),
        ),
        backgroundColor: isDark ? aquaFoam : cyberTeal,
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

  void _openColleges() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CollegesScreen()),
    );
  }

  // فتح شاشة الملاحة (جديد)
  void _openNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ألوان تتغير حسب الوضع
    final Color bg = isDark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
    final Color surface = isDark ? const Color(0xFF042A33) : Colors.white;
    final Color title = isDark ? aquaFoam : cyberTeal;
    final Color sub =
        isDark ? aquaFoam.withAlpha(180) : const Color(0xFF2A7F85);
    final Color avatarBg = isDark ? aquaFoam : cyberTeal;
    final Color avatarFg = isDark ? cyberTeal : aquaFoam;
    final Color mapBox =
        isDark ? const Color(0xFF053844) : aquaFoam.withAlpha(90);
    final Color border = isDark ? const Color(0xFF0B5566) : aquaFoam;
    final Color actionBg =
        isDark ? const Color(0xFF053844) : const Color(0xFFE9FFF9);

    // لو في كلمة بحث، بنعرض النتائج بدل باقي محتوى الصفحة
    final String query = searchController.text.trim();
    final bool searching = query.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,

        // لما التاب "المفضلة" يكون مختار بنعرض شاشة المفضلة جوا نفس الصفحة،
        // فالـ nav bar (اللي تحت) بيضل ظاهر. غير هيك بنعرض الرئيسية.
        body: selectedIndex == _favIndex
            ? FavoritesScreen(
                embedded: true,
                onBrowse: _openColleges,
              )
            : selectedIndex == _accountIndex
            ? AccountScreen(embedded: true, onOpenFavorites: _goToFavorites)
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: avatarBg,
                          child: Icon(Icons.location_on,
                              color: avatarFg, size: 32),
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
                          onPressed: () =>
                              showMessage('لا توجد إشعارات جديدة'),
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
                        gradient: LinearGradient(
                          colors: isDark
                              ? [cyberTeal, const Color(0xFF05505F)]
                              : [aquaFoam.withAlpha(120), aquaFoam],
                        ),
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

                    // Search field (بدون كيبورد على الشاشة)
                    TextField(
                      controller: searchController,
                      style: TextStyle(color: title),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.start,
                      // none = ما بيطلع كيبورد على الشاشة، والكتابة مباشرة بالحقل
                      keyboardType: TextInputType.none,
                      textInputAction: TextInputAction.search,
                      enableSuggestions: false,
                      autocorrect: false,
                      onTap: _hideSystemKeyboard,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن قاعة أو مبنى...',
                        hintStyle: TextStyle(color: sub),
                        prefixIcon: Icon(Icons.search, color: title),
                        suffixIcon: searching
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, color: sub),
                                onPressed: () {
                                  searchController.clear();
                                  FocusScope.of(context).unfocus();
                                  setState(() {});
                                },
                              )
                            : null,
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
                    if (searching)
                      ..._buildSearchResults(
                        query,
                        title,
                        sub,
                        surface,
                        border,
                        avatarBg,
                        avatarFg,
                      )
                    else ...[
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
                            _openNavigation, // <-- تم التعديل: يفتح شاشة الملاحة
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
                            _openColleges,
                            actionBg,
                            border,
                            avatarBg,
                            avatarFg,
                            title,
                            sub),
                        _actionCard(
                            Icons.explore_outlined,
                            'اماكن اخرى',
                            '  مجمع , مكتبة, صالات , كافتيريا ',
                            _goToFavorites,
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
                            _goToAccount,
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
                  ],
                ),
              ),

        // ====================== Curved Bottom Navigation ======================
        bottomNavigationBar: _buildNavBar(bg),
      ),
    );
  }

  // ====================== نتائج البحث ======================
  List<Widget> _buildSearchResults(
    String query,
    Color title,
    Color sub,
    Color surface,
    Color border,
    Color avatarBg,
    Color avatarFg,
  ) {
    final results = searchItHalls(query);

    if (results.isEmpty) {
      return [
        const SizedBox(height: 60),
        Icon(Icons.search_off_rounded, size: 56, color: sub),
        const SizedBox(height: 12),
        Text(
          'ما لقينا قاعة بهالاسم',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'جرّب رقم القاعة مثل 101 أو اسمها مثل it-lab',
          textAlign: TextAlign.center,
          style: TextStyle(color: sub, fontSize: 13.5),
        ),
      ];
    }

    return [
      const SizedBox(height: 22),
      Text(
        'نتائج البحث (${results.length})',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: title,
        ),
      ),
      const SizedBox(height: 12),
      for (final r in results)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItCollegeDetailsPage(
                        initialFloor: r.floorIndex,
                        highlightHall: r.name,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: avatarBg,
                        child: Icon(r.icon, color: avatarFg, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: TextStyle(
                                color: title,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'كلية تكنولوجيا المعلومات • ${r.floorTitle}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: sub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: border.withAlpha(90),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          r.typeLabel,
                          style: TextStyle(
                            color: sub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded, color: sub),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildNavBar(Color pageBg) {
    final int last = _navItems.length - 1;
    final Color barColor = isDark ? const Color(0xFF021F26) : cyberTeal;

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
    // بنخفي أي رسالة (SnackBar) ظاهرة عشان ما تغطي الـ nav bar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => selectedIndex = logical);
  }

  // من كرت "المفضلة" بالوصول السريع: بنحرّك الشريط للتاب
  // (setPage بينادي onTap تلقائياً فبيتبدّل المحتوى)
  void _goToFavorites() {
    _navKey.currentState?.setPage((_navItems.length - 1) - _favIndex);
  }

  // من كرت "حسابي" بالوصول السريع: بنحرّك الشريط لتاب الحساب
  void _goToAccount() {
    _navKey.currentState?.setPage((_navItems.length - 1) - _accountIndex);
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