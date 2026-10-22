import 'package:flutter/material.dart';
import 'map_viewer_screen.dart';
import 'colleges_screen.dart';

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
  int selectedIndex = 0;

  final TextEditingController searchController = TextEditingController();

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
          style: TextStyle(color: isDark ? cyberTeal : aquaFoam),
        ),
        backgroundColor: isDark ? aquaFoam : cyberTeal,
      ),
    );
  }

  // ← جديد: فتح شاشة الخريطة المكبّرة
  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapViewerScreen()),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
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

              // Search field
              TextField(
  controller: searchController,
  style: TextStyle(color: title),
  textDirection: TextDirection.rtl,   // ← اتجاه الكتابة عربي
  textAlign: TextAlign.start,         // ← يبدأ من اليمين
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

                    // ← جديد: صورة الخريطة (بتفتح الخريطة المكبّرة عند الضغط)
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
                        onPressed: openMap, // ← تعديل
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
                    MaterialPageRoute(builder: (_) => const CollegesScreen()),
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
                      () => showMessage('أماكنك المفضلة'),
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
                      () => showMessage('حساب المستخدم'),
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

        // Bottom navigation
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                color: selected ? aquaFoam : Colors.white70,
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: isDark ? const Color(0xFF021F26) : cyberTeal,
            indicatorColor: aquaFoam.withAlpha(60),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
              if (index != 0) {
                showMessage(
                  ['الرئيسية', 'الخريطة', 'المفضلة', 'حسابي'][index],
                );
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.home, color: aquaFoam),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.map, color: aquaFoam),
                label: 'الخريطة',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border, color: Colors.white70),
                selectedIcon: Icon(Icons.bookmark, color: aquaFoam),
                label: 'المفضلة',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.person, color: aquaFoam),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
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