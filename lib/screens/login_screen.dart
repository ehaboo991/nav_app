import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/tappable_logo.dart';
import 'home_page_screens.dart';
import 'user_session_screen.dart'; // جلسة المستخدم (بتغذّي شاشة حسابي)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  /// طول الرقم الجامعي وكلمة المرور
  static const int _idLength = 12;
  static const int _passLength = 6;

  /// عمق انحناء حافة الهيدر السفلية
  static const double _curveDepth = 44;

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _idFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _hidePass = true;
  bool _loading = false;

  // ───────── الأنيميشن (نفس تسلسل الفيديو) ─────────
  late final AnimationController _ctrl;
  late final Animation<double> _reveal; // الهيدر ينزل ويكبر
  late final Animation<double> _titleAnim; // العنوان
  late final Animation<double> _fieldsAnim; // الحقول
  late final Animation<double> _buttonAnim; // زر الدخول
  late final Animation<double> _bottomAnim; // "أو" + الزر السفلي

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ───────── الألوان ─────────
  // داكن: الصفحة Cyber Teal والهيدر Aqua Foam (مثل الفيديو)
  // فاتح: بنعكسهم عشان يضل التباين واضح
  Color get _pageColor =>
      _isDark ? AppColors.cyberTeal : AppColors.aquaFoam;
  Color get _onPage => _isDark ? AppColors.aquaFoam : AppColors.cyberTeal;
  Color get _headerColor =>
      _isDark ? AppColors.aquaFoam : AppColors.cyberTeal;
  Color get _onHeader => _isDark ? AppColors.cyberTeal : AppColors.aquaFoam;

  /// بتخفي كيبورد النظام لو طلع لأي سبب
  void _hideSystemKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  @override
  void initState() {
    super.initState();

    _idFocus.addListener(() {
      if (_idFocus.hasFocus) _hideSystemKeyboard();
    });
    _passFocus.addListener(() {
      if (_passFocus.hasFocus) _hideSystemKeyboard();
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    CurvedAnimation interval(double begin, double end, Curve curve) {
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(begin, end, curve: curve),
      );
    }

    _reveal = interval(0.00, 0.50, Curves.easeOutCubic);
    _titleAnim = interval(0.30, 0.55, Curves.easeOut);
    _fieldsAnim = interval(0.45, 0.72, Curves.easeOut);
    _buttonAnim = interval(0.60, 0.85, Curves.easeOut);
    _bottomAnim = interval(0.75, 1.00, Curves.easeOutCubic);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    _idFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  /// بتجيب بيانات الطالب بعد تسجيل الدخول.
  /// ⚠️ حالياً بترجّع بيانات مؤقتة: الرقم الجامعي من اللي انكتب بالحقل.
  /// TODO: بدّلها بطلب حقيقي (API / Firebase / قاعدة بيانات الجامعة)
  /// وارجع منها الاسم والكلية والتخصص الفعليين.
  Future<UserProfile> _fetchProfile(String studentId, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة التحميل
    return UserProfile(
      name: 'طالب مؤتة',
      studentId: studentId,
      college: 'غير محدد',
      major: 'غير محدد',
    );
  }

  // Login and navigate to Home Page
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      final profile = await _fetchProfile(
        _idCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;

      // بنحفظ المستخدم بالجلسة: شاشة حسابي بتتحدّث تلقائياً
      signIn(profile);

      setState(() => _loading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePageScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);

      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذّر تسجيل الدخول'),
          content: const Text(
              'تأكد من الرقم الجامعي وكلمة المرور وحاول مرة ثانية.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  /// دخول كزائر (الزر السفلي، مثل زر Sign up بالفيديو)
  void _continueAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePageScreen(),
      ),
    );
  }

  // ───────── البناء ─────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _pageColor,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(topPad),
                    Expanded(child: _buildBottom()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// الهيدر الملوّن بحافة منحنية، بينزل ويكبر مثل الفيديو
  Widget _buildHeader(double topPad) {
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, child) {
        return ClipPath(
          clipper: _CurvedHeaderClipper(
            progress: _reveal.value,
            startHeight: topPad + 70,
            curveDepth: _curveDepth,
          ),
          child: child,
        );
      },
      child: Container(
        color: _headerColor,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                topPad + 20,
                24,
                _curveDepth + 28,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الشعار (Hero) - بنحطه بدائرة بلون خلفيته القديمة
                    // عشان يضل واضح فوق الهيدر
                    Center(
                      child: _stagger(
                        _titleAnim,
                        Hero(
                          tag: logoHeroTag,
                          flightShuttleBuilder: logoShuttle,
                          child: Container(
                            width: 104,
                            height: 104,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isDark
                                  ? const Color(0xFF01181E)
                                  : const Color.fromARGB(255, 183, 241, 223),
                            ),
                            child: TappableLogo(size: 80, onTap: () {}),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _stagger(
                      _titleAnim,
                      Column(
                        children: [
                          Text(
                            'MUTAH-NAV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _onHeader,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'سجّل الدخول للمتابعة\nPlease login to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _onHeader.withValues(alpha: 0.7),
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // الرقم الجامعي: 12 رقم فقط
                    _stagger(
                      _fieldsAnim,
                      _field(
                        controller: _idCtrl,
                        focusNode: _idFocus,
                        label: 'الرقم الجامعي / Student ID',
                        icon: Icons.badge_outlined,
                        action: TextInputAction.next,
                        onSubmitted: (_) => _passFocus.requestFocus(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_idLength),
                        ],
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'أدخل الرقم الجامعي';
                          if (v.length != _idLength) {
                            return 'الرقم الجامعي يتكوّن من $_idLength رقم';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // كلمة المرور: 6 أرقام فقط
                    _stagger(
                      _fieldsAnim,
                      _field(
                        controller: _passCtrl,
                        focusNode: _passFocus,
                        label: 'كلمة المرور / Password',
                        icon: Icons.lock_outline,
                        obscure: _hidePass,
                        action: TextInputAction.done,
                        onSubmitted: (_) => _loading ? null : _submit(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_passLength),
                        ],
                        suffix: IconButton(
                          icon: Icon(
                            _hidePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _onHeader.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _hidePass = !_hidePass);
                          },
                        ),
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) return 'أدخل كلمة المرور';
                          if (v.length != _passLength) {
                            return 'كلمة المرور تتكوّن من $_passLength أرقام';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // زر تسجيل الدخول
                    _stagger(
                      _buttonAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _onHeader,
                                foregroundColor: _headerColor,
                                disabledBackgroundColor:
                                    _onHeader.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: _headerColor,
                                      ),
                                    )
                                  : const Text(
                                      'تسجيل الدخول  |  LOGIN',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              // TODO: اربطها بصفحة استعادة كلمة المرور
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    _onHeader.withValues(alpha: 0.75),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                              ),
                              child: const Text(
                                'نسيت كلمة المرور؟  |  Forgot password?',
                                style: TextStyle(fontSize: 11.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // زر الرجوع
            Positioned(
              top: topPad + 4,
              left: 4,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: _onHeader,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// الجزء السفلي: "أو" + الزر الثاني (مثل Sign up بالفيديو)
  Widget _buildBottom() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 20),
        child: Center(
          child: _stagger(
            _bottomAnim,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'أو  |  OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _onPage,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _continueAsGuest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _onPage,
                      foregroundColor: _pageColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'المتابعة كزائر  |  CONTINUE AS GUEST',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
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

  /// ظهور تدريجي + حركة خفيفة لفوق
  Widget _stagger(Animation<double> anim, Widget child, {double dy = 0.15}) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, dy),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // حقول مسطّحة بلون أغمق/أفتح شوي من الهيدر (مثل الفيديو)
    final fill = Color.alphaBlend(
      _onHeader.withValues(alpha: 0.10),
      _headerColor,
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      // none = ما بيطلع كيبورد على الشاشة، والكتابة مباشرة بالحقل
      keyboardType: TextInputType.none,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      onTap: _hideSystemKeyboard,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: _onHeader),
      cursorColor: _onHeader,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _onHeader.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(color: _onHeader),
        prefixIcon: Icon(
          icon,
          color: _onHeader.withValues(alpha: 0.6),
          size: 20,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: fill,
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(_onHeader, width: 1.5),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, width: 1.5),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

/// قصّ الهيدر بحافة سفلية منحنية (شكل ابتسامة) وبتنزل مع الأنيميشن
class _CurvedHeaderClipper extends CustomClipper<Path> {
  _CurvedHeaderClipper({
    required this.progress,
    required this.startHeight,
    required this.curveDepth,
  });

  final double progress;
  final double startHeight;
  final double curveDepth;

  @override
  Path getClip(Size size) {
    final fullBottom = size.height - curveDepth;
    final start = startHeight < fullBottom ? startHeight : fullBottom;
    final y = lerpDouble(start, fullBottom, progress)!;

    return Path()
      ..lineTo(0, y)
      ..quadraticBezierTo(size.width / 2, y + curveDepth * 2, size.width, y)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurvedHeaderClipper old) =>
      old.progress != progress ||
      old.startHeight != startHeight ||
      old.curveDepth != curveDepth;
}