import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'favourite_screen.dart' show favoritesNotifier;
import 'home_page_screens.dart' show themeNotifier;
import 'user_session_screen.dart';
import 'welcome_screen.dart'; // ⚠️ عدّل اسم الملف حسب ملف شاشة الترحيب عندك

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);
const Color _danger = Color(0xFFD64545);

/// شاشة "حسابي"
/// - embedded: true  => معروضة جوا التاب (الـ nav bar بيضل ظاهر)
/// - embedded: false => صفحة مستقلة (فيها زر رجوع)
/// - onOpenFavorites => بتنفّذ لما يضغط على "الأماكن المفضلة" (مثلاً تبديل التاب)
class AccountScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onOpenFavorites;

  const AccountScreen({
    super.key,
    this.embedded = false,
    this.onOpenFavorites,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ---------- بيانات المستخدم (من جلسة تسجيل الدخول) ----------
  UserProfile? get _user => userNotifier.value;
  bool get _isGuest => _user == null;
  String get _name => _user?.name ?? 'زائر';
  String get _studentId => _user?.studentId ?? '—';
  String get _college => _user?.college ?? '—';
  String get _major => _user?.major ?? '—';

  @override
  void initState() {
    super.initState();
    // أي تغيير بالمستخدم (دخول / خروج / تعديل) بيحدّث الشاشة تلقائياً
    userNotifier.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  // ---------- الثيم ----------
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get _surface => _isDark ? const Color(0xFF042A33) : Colors.white;
  Color get _title => _isDark ? _aquaFoam : _cyberTeal;
  Color get _sub =>
      _isDark ? _aquaFoam.withAlpha(165) : const Color(0xFF3F7F85);
  Color get _border =>
      _isDark ? _aquaFoam.withAlpha(40) : _aquaFoam.withAlpha(140);
  Color get _tileBg =>
      _isDark ? _aquaFoam.withAlpha(26) : _aquaFoam.withAlpha(80);
  Color get _shadow => Colors.black.withAlpha(_isDark ? 60 : 14);
  Color get _headerColor =>
      _isDark ? const Color(0xFF021F26) : _cyberTeal;

  void _setDark(bool value) {
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final bottomPad = widget.embedded ? 0.0 : mq.padding.bottom;

    final body = ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 28 + bottomPad),
      children: [
        _buildHeader(topPad),
        _buildIdentity(),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _menuTile(
                icon: Icons.school_outlined,
                title: 'معلوماتي الجامعية',
                subtitle: 'الكلية • المبنى • جدولي الدراسي',
                onTap: _showUniversityInfo,
              ),
              const SizedBox(height: 12),
              _menuTile(
                icon: Icons.star_outline_rounded,
                title: 'الأماكن المفضلة',
                subtitle: 'القاعات • المباني • المسارات المحفوظة',
                onTap: widget.onOpenFavorites ?? () => _info(
                      'الأماكن المفضلة',
                      'افتح تاب المفضلة من الشريط السفلي لعرض أماكنك المحفوظة.',
                    ),
                trailing: _favoritesBadge(),
              ),
              const SizedBox(height: 12),
              _menuTile(
                icon: Icons.translate_rounded,
                title: 'اللغة',
                subtitle: 'العربية / English',
                onTap: _showLanguage,
              ),
              const SizedBox(height: 12),
              _menuTile(
                icon: _isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'المظهر والوضع الليلي',
                subtitle: _isDark ? 'الوضع الليلي مفعّل' : 'تفعيل الوضع الليلي',
                onTap: () => _setDark(!_isDark),
                trailing: Switch(
                  value: _isDark,
                  onChanged: _setDark,
                  activeColor: _cyberTeal,
                  activeTrackColor: _aquaFoam,
                  inactiveThumbColor: _cyberTeal,
                  inactiveTrackColor: _tileBg,
                  trackOutlineColor:
                      WidgetStateProperty.all(Colors.transparent),
                ),
              ),
              const SizedBox(height: 12),
              _menuTile(
                icon: Icons.help_outline_rounded,
                title: 'المساعدة والدعم',
                subtitle: 'الأسئلة الشائعة • تواصل معنا',
                onTap: _showHelp,
              ),
              const SizedBox(height: 12),
              _menuTile(
                icon: Icons.logout_rounded,
                iconColor: _danger,
                iconBg: _danger.withAlpha(_isDark ? 36 : 26),
                title: 'تسجيل الخروج',
                subtitle: 'تسجيل الخروج من حسابك',
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'Mutah-Nav  •  الإصدار 1.0.0',
            style: TextStyle(color: _sub, fontSize: 12),
          ),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: widget.embedded
            ? Material(color: _bg, child: body)
            : Scaffold(backgroundColor: _bg, body: body),
      ),
    );
  }

  // ====================== الهيدر المنحني + الصورة ======================
  Widget _buildHeader(double topPad) {
    final double h = topPad + 170; // ارتفاع الخلفية الداكنة
    const double avatar = 104;

    return SizedBox(
      height: h + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الخلفية المنحنية
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h,
            child: ClipPath(
              clipper: _HeaderClipper(),
              child: Container(color: _headerColor),
            ),
          ),

          // الشريط العلوي: العنوان + زر الرجوع
          Positioned(
            top: topPad + 6,
            left: 14,
            right: 14,
            height: 48,
            child: Row(
              children: [
                const SizedBox(width: 44), // مكان فاضي عشان العنوان يضل بالنص
                const Expanded(
                  child: Center(
                    child: Text(
                      'حسابي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (widget.embedded)
                  const SizedBox(width: 44)
                else
                  _headerBtn(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      textDirection: TextDirection.ltr,
                      color: _aquaFoam,
                      size: 19,
                    ),
                  ),
              ],
            ),
          ),

          // الصورة الرمزية (متداخلة مع المنحنى)
          Positioned(
            top: h - 82,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: avatar,
                height: avatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _bg, // حلقة بلون الخلفية
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: _aquaFoam,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: _cyberTeal,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: GestureDetector(
                        onTap: () => _info(
                          'صورة الحساب',
                          'ميزة تغيير الصورة الشخصية رح تكون متاحة قريباً.',
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _headerColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: _bg, width: 3),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 14,
                            color: _aquaFoam,
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
      ),
    );
  }

  Widget _headerBtn({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withAlpha(24),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }

  // ====================== الاسم والمعلومات ======================
  Widget _buildIdentity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          if (_isGuest)
            Text(
              'سجّل الدخول لعرض بياناتك الجامعية',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sub, fontSize: 13.5),
            )
          else ...[
            Text(
              'الرقم الجامعي: $_studentId',
              style: TextStyle(color: _sub, fontSize: 14),
            ),
            const SizedBox(height: 3),
            Text(
              '$_college  •  تخصص $_major',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sub, fontSize: 13.5),
            ),
          ],
          const SizedBox(height: 16),
          Material(
            color: _tileBg,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _editProfile,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                        color: _title,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_outlined, size: 18, color: _title),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== عناصر القائمة ======================
  Widget _favoritesBadge() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoritesNotifier,
      builder: (context, favs, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (favs.isNotEmpty)
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: _tileBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favs.length}',
                  style: TextStyle(
                    color: _title,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            _chevron(),
          ],
        );
      },
    );
  }

  Widget _chevron() {
    return Icon(
      Icons.chevron_left_rounded,
      textDirection: TextDirection.ltr, // دايماً يشاور لليسار
      color: _sub,
      size: 26,
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _shadow, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg ?? _tileBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor ?? _title, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: _title,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _sub, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ?? _chevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== النوافذ السفلية ======================
  Future<T?> _sheet<T>({required String title, required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: TextStyle(
                    color: _title,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: _sub, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _title,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUniversityInfo() {
    _sheet<void>(
      title: 'معلوماتي الجامعية',
      child: Column(
        children: [
          _infoRow('الاسم', _name),
          Divider(height: 1, color: _border),
          _infoRow('الرقم الجامعي', _studentId),
          Divider(height: 1, color: _border),
          _infoRow('الكلية', _college),
          Divider(height: 1, color: _border),
          _infoRow('التخصص', _major),
          Divider(height: 1, color: _border),
          _infoRow('الجدول الدراسي', 'قريباً'),
        ],
      ),
    );
  }

  void _showLanguage() {
    Widget option(String label, {required bool selected, String? note}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: note == null ? _title : _sub,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (note != null)
              Text(note, style: TextStyle(color: _sub, fontSize: 12.5)),
            if (selected)
              Icon(Icons.check_circle_rounded, color: _title, size: 22),
          ],
        ),
      );
    }

    _sheet<void>(
      title: 'اللغة',
      child: Column(
        children: [
          option('العربية', selected: true),
          Divider(height: 1, color: _border),
          option('English', selected: false, note: 'قريباً'),
        ],
      ),
    );
  }

  void _showHelp() {
    Widget row(IconData icon, String label, String body) {
      return InkWell(
        onTap: () {
          Navigator.pop(context);
          _info(label, body);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: _title, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _title,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _chevron(),
            ],
          ),
        ),
      );
    }

    _sheet<void>(
      title: 'المساعدة والدعم',
      child: Column(
        children: [
          row(
            Icons.quiz_outlined,
            'الأسئلة الشائعة',
            'ابحث عن القاعة من خانة البحث بالرئيسية، أو تصفّح الكليات من الوصول السريع، وأضف الكليات اللي بتهمك للمفضلة.',
          ),
          Divider(height: 1, color: _border),
          row(
            Icons.mail_outline_rounded,
            'تواصل معنا',
            'إذا واجهتك أي مشكلة أو عندك اقتراح، تواصل مع فريق التطبيق.',
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    if (_isGuest) {
      _info('تعديل الملف الشخصي', 'سجّل الدخول أولاً عشان تقدر تعدّل ملفك.');
      return;
    }

    final nameCtrl = TextEditingController(text: _name);
    final majorCtrl = TextEditingController(text: _major);

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _sub),
          filled: true,
          fillColor: _tileBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _title, width: 1.2),
          ),
        );

    final saved = await _sheet<bool>(
      title: 'تعديل الملف الشخصي',
      child: Column(
        children: [
          TextField(
            controller: nameCtrl,
            style: TextStyle(color: _title),
            cursorColor: _title,
            decoration: deco('الاسم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: majorCtrl,
            style: TextStyle(color: _title),
            cursorColor: _title,
            decoration: deco('التخصص'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _isDark ? _aquaFoam : _cyberTeal,
                foregroundColor: _isDark ? _cyberTeal : _aquaFoam,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حفظ',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );

    final newName = nameCtrl.text.trim();
    final newMajor = majorCtrl.text.trim();
    nameCtrl.dispose();
    majorCtrl.dispose();

    final current = userNotifier.value;
    if (saved == true && current != null) {
      // بيحدّث الجلسة، والشاشة بتتحدث لحالها من الـ listener
      userNotifier.value = current.copyWith(
        name: newName.isNotEmpty ? newName : null,
        major: newMajor.isNotEmpty ? newMajor : null,
      );
    }
  }

  // ====================== الحوارات ======================
  Future<void> _info(String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            title,
            style: TextStyle(color: _title, fontWeight: FontWeight.w800),
          ),
          content: Text(
            body,
            style: TextStyle(color: _sub, height: 1.6, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('حسناً', style: TextStyle(color: _title)),
            ),
          ],
        ),
      ),
    );
  }

  /// بترجّع للـ Welcome Screen وبتمسح كل الصفحات السابقة،
  /// فزر الرجوع ما بيرجّع للتطبيق بعد الخروج.
  void _goToWelcome() {
    signOut(); // بيمسح بيانات المستخدم من الجلسة
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmLogout() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'تسجيل الخروج',
            style: TextStyle(color: _title, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'متأكد إنك بدك تسجّل الخروج؟',
            style: TextStyle(color: _sub, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: _sub)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx); // سكّر حوار التأكيد
                _goToWelcome();
              },
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
  }
}

/// قص الخلفية بشكل منحنى: الحواف أنزل من الوسط عشان تنزل الصورة بالنص
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 70,
        size.width,
        size.height,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}