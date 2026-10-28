import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// مسار صورة الكلية (ضيفها في pubspec.yaml تحت assets)
const String _heroImage = 'image/sport.jpeg';

/// مجموعة أماكن داخل تاب (مثلاً: يمين البوابة / يسار البوابة)
class _Group {
  final String label;
  final List<String> items;
  const _Group(this.label, this.items);
}

class _Section {
  final String tab; // عنوان التاب
  final String heading; // عنوان القسم
  final IconData icon;
  final List<_Group> groups; // إذا أكثر من وحدة بيظهر مبدّل يمين/يسار
  const _Section(this.tab, this.heading, this.icon, this.groups);
}

List<_Section> get _sections => const [
  _Section('خارج الكلية', 'خارج مبنى الكلية', Icons.stadium_outlined, [
    _Group('', [
      'ملعب خالد بن الوليد (برا الكلية)',
      'مسبح (برا الكلية)',
    ]),
  ]),
  _Section('الطابق الأرضي', 'الطابق الأرضي', Icons.meeting_room_outlined, [
    _Group('يمين البوابة', [
      'الأمن الجامعي',
      'ديوان',
      'غرفة تصوير',
      'رئيس قسم التأهيل الرياضي',
      'صالة جمباز',
      'مدرج',
      'غرفة غيار الطالبات',
      'صالة إيقاع',
      'قاعة امتحانات',
      'مستودع الأدوات الرياضية',
    ]),
    _Group('يسار البوابة', [
      'مكتب العميد',
      'مكتب نائب العميد',
      'مختبر الفسيولوجيا',
      'غرفة غيار الطلاب',
      'صالة التنس',
      'ملاعب السكواش',
      'الصالة الرياضية',
    ]),
  ]),
  _Section('الطابق الأول', 'الطابق الأول', Icons.stairs_outlined, [
    _Group('', [
      'مختبر الحاسوب',
      'قاعة 101',
      'قاعة 102',
      'قاعة 103',
      'قاعة 104',
      'قاعة 105',
      'قاعة 106',
      'قاعة 107',
    ]),
  ]),
];

class SportCollegeDetailsPage extends StatefulWidget {
  const SportCollegeDetailsPage({super.key});

  @override
  State<SportCollegeDetailsPage> createState() =>
      _SportCollegeDetailsPageState();
}

class _SportCollegeDetailsPageState extends State<SportCollegeDetailsPage> {
  int _tab = 0;
  int _sub = 0; // يمين = 0 ، يسار = 1

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get _surface => _isDark ? const Color(0xFF042A33) : Colors.white;
  Color get _title => _isDark ? _aquaFoam : _cyberTeal;
  Color get _sub2 =>
      _isDark ? _aquaFoam.withAlpha(170) : const Color(0xFF2A7F85);
  Color get _border =>
      _isDark ? _aquaFoam.withAlpha(45) : _aquaFoam.withAlpha(150);
  Color get _tileBg =>
      _isDark ? _aquaFoam.withAlpha(28) : _aquaFoam.withAlpha(85);

  void _showImage() {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(ctx),
        child: Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SizedBox.expand(
            child: InteractiveViewer(
              child: Image.asset(
                _heroImage,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = _sections[_tab];
    final group = section.groups[_sub.clamp(0, section.groups.length - 1)];
    final hasSwitch = section.groups.length > 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _hero(context)),
            SliverToBoxAdapter(child: _tabs()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  section.heading,
                  style: TextStyle(
                    color: _title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (hasSwitch)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                sliver: SliverToBoxAdapter(child: _switcher(section)),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              sliver: SliverList.separated(
                itemCount: group.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _item(section, group, i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- مبدّل يمين / يسار ----------------
  Widget _switcher(_Section s) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: List.generate(s.groups.length, (i) {
          final on = _sub == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sub = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? (_isDark ? _aquaFoam : _cyberTeal) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  s.groups[i].label,
                  style: TextStyle(
                    color: on
                        ? (_isDark ? _cyberTeal : Colors.white)
                        : _title,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------- الهيرو ----------------
  Widget _hero(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: _showImage,
      child: Container(
      height: 270 + top * 0.3,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _heroImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF03303B), Color(0xFF0A6475)],
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(60),
                  Colors.transparent,
                  Colors.black.withAlpha(170),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: top + 12,
            right: 16,
            child: _glassBtn(Icons.arrow_forward_ios_rounded,
                () => Navigator.of(context).maybePop()),
          ),
          Positioned(
            right: 20,
            left: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'كلية علوم الرياضة',
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
                    'Faculty of Sport Sciences',
                    style: TextStyle(
                      fontSize: 13,
                      color: _aquaFoam.withAlpha(230),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withAlpha(45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // ---------------- التابات ----------------
  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: List.generate(_sections.length, (i) {
          final on = _tab == i;
          final fg = on ? (_isDark ? _cyberTeal : Colors.white) : _title;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: i == _sections.length - 1 ? 0 : 10),
              child: GestureDetector(
                onTap: () => setState(() {
                  _tab = i;
                  _sub = 0;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 88,
                  decoration: BoxDecoration(
                    color: on ? (_isDark ? _aquaFoam : _cyberTeal) : _surface,
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: on ? Colors.transparent : _border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: on ? _aquaFoam : _title,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: on
                                ? _cyberTeal
                                : (_isDark ? _cyberTeal : Colors.white),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _sections[i].tab,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fg,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
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

  // ---------------- عنصر القائمة ----------------
  Widget _item(_Section s, _Group g, int i) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$_tab-$_sub-$i'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (i.clamp(0, 8)) * 50),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration:
                  BoxDecoration(color: _tileBg, shape: BoxShape.circle),
              child: Icon(s.icon, size: 19, color: _title),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                g.items[i],
                style: TextStyle(
                  color: _title,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}