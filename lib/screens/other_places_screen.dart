import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'; // حركة الظهور واحد ورا الثاني
import 'favourite_screen.dart' show favoritesNotifier, toggleFavorite;
import 'home_page_screens.dart' show cyberTeal, aquaFoam;

/// لون القلب (نفس اللون المستخدم بشاشة الكليات وشاشة المفضلة)
const Color _heartRed = Color(0xFFFF4D6D);

/// انتقال بطيء: بيخلي حركة الـ Hero (الصورة بتكبر من الكرت) أبطأ
const Duration _slowDuration = Duration(milliseconds: 400); // غيّر الرقم حسب ذوقك

/// ظهور الكروت واحد ورا الثاني (Staggered)
const int _staggerMs = 250; // الفاصل بين كل كرت والتاني (زيدو لو بدك أبطأ)
const int _staggerMaxItems = 10; // آخر كرت بياخد تأخير، الباقي بيظهر معه

/// تلاشي + انزلاق من تحت، والكرت رقم i بيتأخر i × 80ms
Widget _appear(int i, Widget child) {
  return child
      .animate(delay: (_staggerMs * i.clamp(0, _staggerMaxItems)).ms)
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideY(
        begin: 0.2,
        end: 0,
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      );
}

Route<T> _slowRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: _slowDuration,
    reverseTransitionDuration: _slowDuration,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
  );
}

class _Hall {
  final String nameAr;
  final String nameEn;
  final String image;
  final IconData icon;

  /// إذا true، الضغط على الكرت بيفتح صفحة معلومات المجمع
  final bool hasDetails;
  const _Hall(
    this.nameAr,
    this.nameEn,
    this.image, [
    this.icon = Icons.meeting_room_rounded,
    this.hasDetails = false,
  ]);
}

// غيّر أسماء ملفات الصور هون حسب الموجود عندك بمجلد image/
const List<_Hall> _halls = [
  _Hall('الصالة الهاشمية', 'Hashemite Hall', 'image/hashimate.jpeg'),
  _Hall('الصالة الأموية', 'Umayyad Hall', 'image/amoiah.jpeg'),
  _Hall('الصالة العباسية', 'Abbasid Hall', 'image/abbasid_hall.jpeg'),
];

// المجمعات: غيّر أسماء ملفات الصور حسب الموجود عندك بمجلد image/
const List<_Hall> _complexes = [
  _Hall(
    'مجمع الشريف الحسين بن علي (المجمع القديم)',
    'Sharif Al-Hussein Bin Ali Complex (Old Complex)',
    'image/old complex2.jpeg',
    Icons.business_rounded,
    true,
  ),
  _Hall(
    'مجمع الكندي',
    'Al-Kindi Complex',
    'image/alkindi.jpeg',
    Icons.business_rounded,
    true, // صار بيفتح صفحة المعلومات
  ),
  _Hall(
    'مجمع الشهيد',
    'Al-Shaheed Complex',
    'image/shaheed_complex.jpeg',
    Icons.business_rounded,
  ),
];

class OtherPlacesScreen extends StatefulWidget {
  /// التاب اللي بيفتح عليه: 0 = الصالات | 1 = المجمعات | 2 = المكتبة
  final int initialTab;
  const OtherPlacesScreen({super.key, this.initialTab = 0});

  @override
  State<OtherPlacesScreen> createState() => _OtherPlacesScreenState();
}

class _OtherPlacesScreenState extends State<OtherPlacesScreen> {
  /// 0 = الصالات | 1 = المجمعات | 2 = المكتبة
  late int _tab = widget.initialTab;

  List<_Hall> get _currentList => _tab == 0 ? _halls : _complexes;

  void _openComplex(_Hall hall) {
    Navigator.push(
      context,
      _slowRoute(_ComplexDetailsScreen(hall: hall)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? Color.alphaBlend(Colors.black.withAlpha(150), cyberTeal)
        : Color.alphaBlend(aquaFoam.withAlpha(40), Colors.white);
    final title = dark ? aquaFoam : cyberTeal;
    final sub = dark ? aquaFoam.withAlpha(170) : cyberTeal.withAlpha(150);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // الهيدر
              Row(
                children: [
                  Material(
                    color: dark ? Colors.white.withAlpha(20) : Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: title.withAlpha(50)),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(Icons.arrow_back_rounded,
                            color: title, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'أماكن أخرى',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // أزرار التبديل: الصالات | المجمعات | المكتبة (بتضل ظاهرة دايماً)
              _TabSwitcher(
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
                title: title,
                dark: dark,
                items: const [
                  _TabItem('الصالات', Icons.meeting_room_rounded),
                  _TabItem('المجمعات', Icons.business_rounded),
                  _TabItem('المكتبة', Icons.local_library_rounded),
                ],
              ),
              const SizedBox(height: 18),

              // المحتوى حسب الزر المختار
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tab == 2
                    ? LibraryContent(
                        key: const ValueKey('library'),
                        dark: dark,
                        title: title,
                        sub: sub,
                      )
                    : Column(
                        key: ValueKey(_tab),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < _currentList.length; i++) ...[
                            _appear(
                              i,
                              _HallCard(
                                hall: _currentList[i],
                                dark: dark,
                                onTap: _currentList[i].hasDetails
                                    ? () => _openComplex(_currentList[i])
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}

/// أزرار التبديل بين الأقسام (الصالات | المجمعات | المكتبة)
class _TabSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final List<_TabItem> items;
  final Color title;
  final bool dark;

  const _TabSwitcher({
    required this.selected,
    required this.onChanged,
    required this.items,
    required this.title,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = dark ? aquaFoam : cyberTeal;
    final activeFg = dark ? cyberTeal : aquaFoam;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withAlpha(18) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: title.withAlpha(40)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: i == selected ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 18,
                        color: i == selected ? activeFg : title,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: i == selected ? activeFg : title,
                          ),
                        ),
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

/// زر القلب: فاضي = مش مفضل | معبّى أحمر = مفضل
/// مربوط بمخزن المفضلة المشترك (favoritesNotifier) الموجود بشاشة المفضلة،
/// والمفتاح هو الاسم العربي للمكان.
class _FavButton extends StatelessWidget {
  final String id;
  const _FavButton({required this.id});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoritesNotifier,
      builder: (context, favs, child) {
        final isFav = favs.contains(id);
        return Material(
          color: cyberTeal.withAlpha(210),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              final added = toggleFavorite(id);
              HapticFeedback.lightImpact();

              final dark = Theme.of(context).brightness == Brightness.dark;
              final bg = dark ? aquaFoam : cyberTeal;
              final fg = dark ? cyberTeal : aquaFoam;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    backgroundColor: bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Icon(
                            added
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: added ? _heartRed : fg,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              added
                                  ? 'تمت إضافة $id إلى المفضلة'
                                  : 'تمت إزالة $id من المفضلة',
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFav),
                  color: isFav ? _heartRed : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// كرت المكان: صورة بالخلفية + تدرج + الاسم عربي/إنجليزي + أزرار دائرية
class _HallCard extends StatelessWidget {
  final _Hall hall;
  final bool dark;

  /// إذا انعطى، بيتنفذ بدل عرض الصورة بملء الشاشة
  final VoidCallback? onTap;

  /// ارتفاع الكرت (الافتراضي 210)
  final double height;
  const _HallCard({
    required this.hall,
    required this.dark,
    this.onTap,
    this.height = 210,
  });

  void _openFull(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    Navigator.push(
      context,
      _slowRoute(_FullImageScreen(hall: hall)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withAlpha(110)
                : cyberTeal.withAlpha(45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة
            GestureDetector(
              onTap: () => _openFull(context),
              child: Hero(
                tag: 'hall_${hall.image}',
                child: Image.asset(
                  hall.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, _) {
                    debugPrint('Hall image failed: ${hall.image} -> $error');
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [cyberTeal, Color(0xFF0A5566)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        hall.icon,
                        size: 70,
                        color: aquaFoam.withAlpha(90),
                      ),
                    );
                  },
                ),
              ),
            ),

            // التدرج
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(60),
                      Colors.transparent,
                      cyberTeal.withAlpha(120),
                      cyberTeal.withAlpha(235),
                    ],
                    stops: const [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // الاسم عربي + إنجليزي
            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 18,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hall.nameAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hall.nameEn,
                      style: const TextStyle(
                        color: aquaFoam,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // زر السهم (أعلى اليمين)
            Positioned(
              top: 14,
              right: 14,
              child: _circleButton(
                Icons.chevron_right_rounded,
                () => _openFull(context),
                highlighted: true,
              ),
            ),

            // زر المفضلة (أقصى اليسار)
            Positioned(
              top: 14,
              left: 14,
              child: _FavButton(id: hall.nameAr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap,
      {bool highlighted = false}) {
    return Material(
      color: highlighted
          ? aquaFoam.withAlpha(90)
          : Colors.black.withAlpha(90),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// عرض الصورة بملء الشاشة مع تكبير بالإصبعين
class _FullImageScreen extends StatelessWidget {
  final _Hall hall;
  const _FullImageScreen({required this.hall});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(hall.nameAr),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Hero(
                tag: 'hall_${hall.image}',
                child: Image.asset(
                  hall.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported_outlined,
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

// صورة الغلاف من جوا (غيّر الاسم حسب الموجود عندك بمجلد image/)
const String _kInsideCover = 'image/lib.jpeg';

class _LibItem {
  final String ar;
  final String en;
  final IconData icon;

  /// اتجاه السهم كما هو مكتوب على لوحة المكتبة: -1 يسار | 1 يمين | 0 بدون
  final int dir;
  const _LibItem(this.ar, this.en, this.icon, [this.dir = 0]);
}

class _Floor {
  final String ar;
  final String en;
  final List<_LibItem> items;
  const _Floor(this.ar, this.en, this.items);
}

// المعلومات مأخوذة من لوحة "وحدة المكتبة"
const List<_Floor> _floors = [
  _Floor('الطابق الأرضي', 'Ground Floor', [
    _LibItem('الرسائل الجامعية والمجموعات الخاصة',
        'Dissertations & Special Collection', Icons.school_rounded),
    _LibItem('القاعة الهاشمية', 'The Hashemite Hall',
        Icons.meeting_room_rounded),
    _LibItem('الإهداء والتبادل', 'Gift & Exchange',
        Icons.card_giftcard_rounded),
    _LibItem('الأرشفة والمواد المصغرة', 'Archiving and Microfilms',
        Icons.archive_rounded),
    _LibItem('التصوير الفوتستاتي', 'Photostatic Copying',
        Icons.print_rounded),
  ]),
  _Floor('الطابق الأول', 'First Floor', [
    _LibItem('الإدارة', 'Administration',
        Icons.admin_panel_settings_rounded, -1),
    _LibItem('الإعارة', 'Circulation Desk', Icons.swap_horiz_rounded, 1),
    _LibItem('التزويد', 'Acquisition', Icons.add_shopping_cart_rounded, 1),
    _LibItem('الفهرسة والتصنيف', 'Cataloguing & Classification',
        Icons.category_rounded, 1),
    _LibItem('التجليد والترميم', 'Binding and Restoration',
        Icons.build_rounded, 1),
    _LibItem('الكتب العامة العربية', 'General Collection of Arabic Books',
        Icons.menu_book_rounded),
    _LibItem('مكتبة المناهج الجامعية', 'University Curriculum Library',
        Icons.auto_stories_rounded, -1),
  ]),
  _Floor('الطابق الثاني', 'Second Floor', [
    _LibItem('الكتب العامة العربية', 'General Collection of Arabic Books',
        Icons.menu_book_rounded),
    _LibItem('الكتب العامة الأجنبية', 'General Collection of Foreign Books',
        Icons.language_rounded),
  ]),
  _Floor('الطابق الثالث', 'Third Floor', [
    _LibItem('الدوريات العربية والأجنبية', 'Arabic & Foreign Periodicals',
        Icons.newspaper_rounded),
    _LibItem('المكتبة الإلكترونية', 'Digital Library',
        Icons.devices_rounded),
    _LibItem('مختبر الحاسوب', 'Computer Lab',
        Icons.desktop_windows_rounded),
  ]),
  _Floor('الطابق الرابع', 'Fourth Floor', [
    _LibItem('المراجع العربية والأجنبية', 'Arabic and Foreign References',
        Icons.bookmarks_rounded),
  ]),
];

/// محتوى المكتبة (بدون Scaffold) — بيظهر تحت الشريط جوا نفس الشاشة
class LibraryContent extends StatefulWidget {
  final bool dark;
  final Color title;
  final Color sub;

  const LibraryContent({
    super.key,
    required this.dark,
    required this.title,
    required this.sub,
  });

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  /// الطابق المختار (0 = الأرضي ... 4 = الرابع)
  int _floor = 0;

  /// الضغط على الكرت يعرض الصورة كاملة، والضغط على أي مكان فيها يرجّعك
  void _openCoverFull() {
    Navigator.push(
      context,
      _slowRoute(
        const _FullImageScreen(
          hall: _Hall('مكتبة الجامعة', 'University Library', _kInsideCover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final title = widget.title;
    final sub = widget.sub;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // كرت صورة المكتبة (بنفس شكل كروت الصالات)
        _HallCard(
          hall: const _Hall(
            'مكتبة الجامعة',
            'University Library',
            _kInsideCover,
            Icons.local_library_rounded,
          ),
          dark: dark,
          onTap: _openCoverFull,
          height: 290, // 252 × 1.15
        ),
        const SizedBox(height: 24),

        // عنوان القسم: أيقونة + عنوان + وصف
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: title.withAlpha(dark ? 30 : 22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.local_library_rounded,
                  color: title, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وحدة المكتبة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: title,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'الطوابق والأقسام  •  Floors & Sections',
                    style: TextStyle(fontSize: 12.5, color: sub),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // أزرار الطوابق
        _FloorButtons(
          selected: _floor,
          onChanged: (i) => setState(() => _floor = i),
          dark: dark,
          title: title,
          // "الطابق الأول" -> "الأول"
          labels: [
            for (final f in _floors) f.ar.replaceFirst('الطابق ', ''),
          ],
          badges: [for (int i = 0; i < _floors.length; i++) '$i'],
        ),
        const SizedBox(height: 16),

        // أقسام الطابق المختار
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _FloorCard(
            key: ValueKey(_floor),
            floor: _floors[_floor],
            dark: dark,
            title: title,
            sub: sub,
          ),
        ),
      ],
    );
  }
}

/// أزرار الطوابق: كرت لكل طابق فيه مربع الرقم واسم الطابق
class _FloorButtons extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final bool dark;
  final Color title;

  /// اسم كل طابق (مثلاً "الأول") ورقمه داخل المربع
  final List<String> labels;
  final List<String> badges;

  const _FloorButtons({
    required this.selected,
    required this.onChanged,
    required this.dark,
    required this.title,
    required this.labels,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = dark ? aquaFoam : cyberTeal;
    final activeFg = dark ? cyberTeal : aquaFoam;

    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i != 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: 86,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  color: i == selected
                      ? activeBg
                      : (dark ? Colors.white.withAlpha(18) : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: i == selected ? activeBg : title.withAlpha(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // مربع رقم الطابق (بالنص)
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == selected ? activeFg : title,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badges[i],
                        style: TextStyle(
                          color: i == selected ? activeBg : activeFg,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // اسم الطابق بالنص: "الطابق الأول" -> "الأول"
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          labels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: i == selected ? activeFg : title,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FloorCard extends StatelessWidget {
  final _Floor floor;
  final bool dark;
  final Color title;
  final Color sub;

  const _FloorCard({
    super.key,
    required this.floor,
    required this.dark,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = dark ? aquaFoam : cyberTeal;
    final activeFg = dark ? cyberTeal : aquaFoam;

    return Container(
      decoration: BoxDecoration(
        color: dark ? Colors.white.withAlpha(14) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: title.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withAlpha(90)
                : cyberTeal.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان الطابق
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: activeBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(21)),
            ),
            child: Row(
              children: [
                Icon(Icons.layers_rounded, color: activeFg, size: 22),
                const SizedBox(width: 10),
                Text(
                  floor.ar,
                  style: TextStyle(
                    color: activeFg,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  floor.en,
                  style: TextStyle(
                    color: activeFg.withAlpha(200),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          // أقسام الطابق
          for (int i = 0; i < floor.items.length; i++) ...[
            _ItemRow(item: floor.items[i], dark: dark, title: title, sub: sub),
            if (i != floor.items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: title.withAlpha(25),
              ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final _LibItem item;
  final bool dark;
  final Color title;
  final Color sub;

  const _ItemRow({
    required this.item,
    required this.dark,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: title.withAlpha(dark ? 30 : 22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: title, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ar,
                  style: TextStyle(
                    color: title,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.en,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: sub, fontSize: 11.5),
                ),
              ],
            ),
          ),
          if (item.dir != 0) ...[
            const SizedBox(width: 8),
            // west/east أيقونات ثابتة الاتجاه (ما بتنعكس مع RTL)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: title.withAlpha(dark ? 30 : 22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.dir < 0 ? Icons.west_rounded : Icons.east_rounded,
                color: title,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  صفحة معلومات المجمع (كل طابق لحاله)
// ════════════════════════════════════════════════════════════════

class _InfoGroup {
  final String title;
  final IconData icon;

  /// سطر توضيحي تحت العنوان
  final String? note;

  /// البنود تحت العنوان
  final List<String> items;

  /// إذا true، البنود بتنعرض كشارات صغيرة (مناسبة لأرقام القاعات)
  final bool chips;

  const _InfoGroup(
    this.title,
    this.icon, {
    this.note,
    this.items = const [],
    this.chips = false,
  });
}

class _ComplexFloor {
  final String ar;
  final String en;
  final List<_InfoGroup> groups;
  const _ComplexFloor(this.ar, this.en, this.groups);
}

const List<_ComplexFloor> _oldComplexFloors = [
  _ComplexFloor('الطابق الأول', 'First Floor', [
    _InfoGroup(
      'قاعات التدريس',
      Icons.class_rounded,
      items: ['120', '121', '122', '123', '126'],
      chips: true,
    ),
    _InfoGroup('مدرج 4', Icons.event_seat_rounded),
    _InfoGroup(
      'يسار البوابة الرئيسية',
      Icons.west_rounded,
      note: 'قسم خاص بأعضاء هيئة التدريس والمراقبين',
      items: [
        'قاعة تمكين المرأة',
        'مكتب موظفي الريادة والابتكار',
        'مكتب رئيس فرع مراقبي القاعات',
      ],
    ),
    _InfoGroup(
      'يمين البوابة الرئيسية',
      Icons.east_rounded,
      note: 'مركز الريادة والابتكار، ويحتوي على:',
      items: [
        'قاعة للطلاب',
        'معرض تقني',
        'قاعة اجتماعات',
      ],
    ),
    _InfoGroup(
      'المرافق',
      Icons.wc_rounded,
      items: [
        'دورات مياه للجميع (WC for all)',
        'كافتيريا صغيرة',
      ],
    ),
  ]),
  _ComplexFloor('الطابق الثاني', 'Second Floor', [
    _InfoGroup(
      'كلية العلوم التربوية',
      Icons.construction_rounded,
      note: 'الدبلوم العالي — قيد الإنشاء',
    ),
    _InfoGroup(
      'قاعات التدريس',
      Icons.class_rounded,
      note: 'لم يتم تحديدها بعد',
    ),
  ]),
];

/// طوابق مجمع الكندي
const List<_ComplexFloor> _kindiFloors = [
  _ComplexFloor('الطابق الأول', 'First Floor', [
    _InfoGroup(
      'قاعات التدريس',
      Icons.class_rounded,
      items: ['101', '102', '103', '104', '105', '106'],
      chips: true,
    ),
    _InfoGroup(
      'المدرجات',
      Icons.event_seat_rounded,
      items: ['مدرج الخوارزمي', 'مدرج'],
    ),
    _InfoGroup(
      'قاعة متعددة الأغراض 1',
      Icons.groups_rounded,
    ),
    _InfoGroup(
      'مكتب الأمن الجامعي',
      Icons.security_rounded,
    ),
    _InfoGroup(
      'المرافق',
      Icons.wc_rounded,
      items: ['حمام طلاب', 'حمام طالبات'],
    ),
  ]),
  _ComplexFloor('الطابق الثاني', 'Second Floor', [
    _InfoGroup(
      'قاعات التدريس',
      Icons.class_rounded,
      items: ['201', '202', '203', '205', '206', '207', '208', '209'],
      chips: true,
    ),
    _InfoGroup(
      'مدرج',
      Icons.event_seat_rounded,
    ),
    _InfoGroup(
      'قاعة متعددة الأغراض 2',
      Icons.groups_rounded,
    ),
    _InfoGroup(
      'المرافق',
      Icons.wc_rounded,
      items: [
        'حمام طالبات',
        'حمام طلاب (1)',
        'حمام طلاب (2)',
      ],
    ),
  ]),
  _ComplexFloor('الطابق الثالث', 'Third Floor', [
    _InfoGroup(
      'قاعات التدريس',
      Icons.class_rounded,
      items: ['203', '205', '206', '207', '208', '209', '210'],
      chips: true,
    ),
    _InfoGroup(
      'قاعة Modeling Room',
      Icons.view_in_ar_rounded,
    ),
    _InfoGroup(
      'المختبرات',
      Icons.computer_rounded,
      items: ['Lab B – 211', 'Lab A – 212'],
    ),
    _InfoGroup(
      'Studio 1A – 203',
      Icons.draw_rounded,
    ),
    _InfoGroup(
      'قسم العمارة (Architecture Department)',
      Icons.architecture_rounded,
      items: [
        '200 – مكتب القسم (Department Office)',
        '201 – مكتب أعضاء هيئة التدريس (Faculty Office)',
        '202 – مكتب أعضاء هيئة التدريس (Faculty Office)',
      ],
    ),
    _InfoGroup(
      'المرافق',
      Icons.wc_rounded,
      items: ['حمام طلاب (1)', 'حمام طلاب (2)', 'حمام طلاب (3)'],
    ),
  ]),
];

class _ComplexDetailsScreen extends StatefulWidget {
  final _Hall hall;
  const _ComplexDetailsScreen({required this.hall});

  @override
  State<_ComplexDetailsScreen> createState() => _ComplexDetailsScreenState();
}

class _ComplexDetailsScreenState extends State<_ComplexDetailsScreen> {
  int _floor = 0;

  /// طوابق المجمع الحالي
  List<_ComplexFloor> get _complexFloors =>
      widget.hall.nameAr == 'مجمع الكندي' ? _kindiFloors : _oldComplexFloors;

  void _openCoverFull() {
    Navigator.push(
      context,
      _slowRoute(_FullImageScreen(hall: widget.hall)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? Color.alphaBlend(Colors.black.withAlpha(150), cyberTeal)
        : Color.alphaBlend(aquaFoam.withAlpha(40), Colors.white);
    final title = dark ? aquaFoam : cyberTeal;
    final sub = dark ? aquaFoam.withAlpha(170) : cyberTeal.withAlpha(150);
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            slivers: [
              // الغلاف: صورة بزوايا سفلية دائرية، الضغط عليها يعرضها كاملة
              SliverToBoxAdapter(
                child: Container(
                  height: 280 + top,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dark
                            ? Colors.black.withAlpha(110)
                            : cyberTeal.withAlpha(45),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: _openCoverFull,
                          // Hero: الصورة بتطير من الكرت لغلاف الصفحة (نفس tag الكرت)
                          child: Hero(
                            tag: 'hall_${hall.image}',
                            child: Image.asset(
                              hall.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, _) {
                                debugPrint('Complex cover failed: $error');
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [cyberTeal, Color(0xFF0A5566)],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    hall.icon,
                                    size: 80,
                                    color: aquaFoam.withAlpha(90),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // التدرج
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(60),
                                  Colors.transparent,
                                  cyberTeal.withAlpha(110),
                                  cyberTeal.withAlpha(230),
                                ],
                                stops: const [0.0, 0.35, 0.72, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // الاسم عربي + إنجليزي
                        PositionedDirectional(
                          start: 24,
                          end: 24,
                          bottom: 26,
                          child: IgnorePointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hall.nameAr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hall.nameEn,
                                  style: const TextStyle(
                                    color: aquaFoam,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // زر الرجوع (أعلى اليمين)
                        Positioned(
                          top: top + 12,
                          right: 16,
                          child: Material(
                            color: aquaFoam.withAlpha(90),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.pop(context),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                // LTR عشان السهم يضل ">" وما ينعكس مع RTL
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // عنوان القسم
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: title.withAlpha(dark ? 30 : 22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.business_rounded,
                              color: title, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'معلومات المجمع',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: title,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'الطوابق والأقسام  •  Floors & Sections',
                                style: TextStyle(fontSize: 12.5, color: sub),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // أزرار الطوابق
                    _FloorButtons(
                      selected: _floor,
                      onChanged: (i) => setState(() => _floor = i),
                      dark: dark,
                      title: title,
                      labels: [
                        for (final f in _complexFloors)
                          f.ar.replaceFirst('الطابق ', ''),
                      ],
                      badges: [
                        for (int i = 0; i < _complexFloors.length; i++)
                          '${i + 1}',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // معلومات الطابق المختار
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _ComplexFloorCard(
                        key: ValueKey(_floor),
                        floor: _complexFloors[_floor],
                        dark: dark,
                        title: title,
                        sub: sub,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplexFloorCard extends StatelessWidget {
  final _ComplexFloor floor;
  final bool dark;
  final Color title;
  final Color sub;

  const _ComplexFloorCard({
    super.key,
    required this.floor,
    required this.dark,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = dark ? aquaFoam : cyberTeal;
    final activeFg = dark ? cyberTeal : aquaFoam;

    return Container(
      decoration: BoxDecoration(
        color: dark ? Colors.white.withAlpha(14) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: title.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withAlpha(90)
                : cyberTeal.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان الطابق
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: activeBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(21)),
            ),
            child: Row(
              children: [
                Icon(Icons.layers_rounded, color: activeFg, size: 22),
                const SizedBox(width: 10),
                Text(
                  floor.ar,
                  style: TextStyle(
                    color: activeFg,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  floor.en,
                  style: TextStyle(
                    color: activeFg.withAlpha(200),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          // مجموعات الطابق
          for (int i = 0; i < floor.groups.length; i++) ...[
            _GroupBlock(
              group: floor.groups[i],
              dark: dark,
              title: title,
              sub: sub,
            ),
            if (i != floor.groups.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: title.withAlpha(25),
              ),
          ],
        ],
      ),
    );
  }
}

class _GroupBlock extends StatelessWidget {
  final _InfoGroup group;
  final bool dark;
  final Color title;
  final Color sub;

  const _GroupBlock({
    required this.group,
    required this.dark,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + الأيقونة + السطر التوضيحي
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: title.withAlpha(dark ? 30 : 22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(group.icon, color: title, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: TextStyle(
                        color: title,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (group.note != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.note!,
                        style: TextStyle(color: sub, fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // البنود
          if (group.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (group.chips)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 52),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in group.items)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: title.withAlpha(dark ? 30 : 22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: title.withAlpha(40)),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: title,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              for (final item in group.items)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 52, bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: title.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: title,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  واجهة عامة تستخدمها شاشة المفضلة
// ════════════════════════════════════════════════════════════════

/// مكتبة الجامعة (بتنعرض ككرت بتاب المكتبة)
const _Hall _libraryHall = _Hall(
  'مكتبة الجامعة',
  'University Library',
  _kInsideCover,
  Icons.local_library_rounded,
);

final List<_Hall> _allPlaces = [..._halls, ..._complexes, _libraryHall];

/// معلومات مكان بسيطة (عامة) لعرضه بشاشة المفضلة
class PlaceInfo {
  final String nameAr;
  final String nameEn;
  final String image;
  final IconData icon;
  const PlaceInfo(this.nameAr, this.nameEn, this.image, this.icon);
}

/// كل الأماكن اللي ممكن تنضاف للمفضلة
List<PlaceInfo> get favoritablePlaces => [
      for (final h in _allPlaces)
        PlaceInfo(h.nameAr, h.nameEn, h.image, h.icon),
    ];

/// بتفتح المكان: صفحة المعلومات إذا إلو (المجمع القديم / الكندي)، وإلا الصورة بملء الشاشة
void openPlace(BuildContext context, String nameAr) {
  final hall = _allPlaces.firstWhere((h) => h.nameAr == nameAr);
  Navigator.push(
    context,
    _slowRoute(
      hall.hasDetails
          ? _ComplexDetailsScreen(hall: hall)
          : _FullImageScreen(hall: hall),
    ),
  );
}

/// الصالات (للشريط الجانبي)
List<PlaceInfo> get hallPlaces => [
      for (final h in _halls) PlaceInfo(h.nameAr, h.nameEn, h.image, h.icon),
    ];

/// المجمعات (للشريط الجانبي)
List<PlaceInfo> get complexPlaces => [
      for (final h in _complexes)
        PlaceInfo(h.nameAr, h.nameEn, h.image, h.icon),
    ];

/// المكتبة (للشريط الجانبي)
PlaceInfo get libraryPlace => PlaceInfo(
      _libraryHall.nameAr,
      _libraryHall.nameEn,
      _libraryHall.image,
      _libraryHall.icon,
    );

/// بتفتح صفحة الأماكن الأخرى مباشرة على تاب المكتبة
void openLibrary(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const OtherPlacesScreen(initialTab: 2)),
  );
}