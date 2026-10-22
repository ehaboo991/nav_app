import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/tappable_logo.dart';
import 'home_page_screens.dart'; // ← التعديل: نفس اسم الملف الفعلي

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _open = false;
  bool _hidePass = true;
  bool _loading = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Login and navigate to Home Page
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    // Temporary loading simulation
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _loading = false);

    // Open HomePageScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark
        ? const Color(0xFF01181E)
        : const Color.fromARGB(255, 183, 241, 223);
    final mainColor = _isDark ? AppColors.aquaFoam : AppColors.cyberTeal;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: mainColor,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated logo
                    Hero(
                      tag: logoHeroTag,
                      flightShuttleBuilder: logoShuttle,
                      child: AnimatedScale(
                        scale: _open ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        child: TappableLogo(
                          size: 130,
                          onTap: () {
                            setState(() => _open = !_open);
                          },
                        ),
                      ),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _open
                          ? const SizedBox.shrink()
                          : Padding(
                              key: const ValueKey('hint'),
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'اضغط على الشعار لتسجيل الدخول\n'
                                'Tap the logo to sign in',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: mainColor.withOpacity(0.7),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                    ),

                    // Animated login form
                    AnimatedSize(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: _open
                            ? _buildForm()
                            : const SizedBox(
                                key: ValueKey('empty'),
                                width: double.infinity,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final mainColor = _isDark ? AppColors.aquaFoam : AppColors.cyberTeal;
    final cardColor =
        _isDark ? const Color(0xFF042A33) : AppColors.aquaFoamLight;

    return Container(
      key: const ValueKey('form'),
      constraints: const BoxConstraints(maxWidth: 420),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: mainColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyberTeal.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'مرحباً بك  •  Welcome',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mainColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _field(
              controller: _idCtrl,
              label: 'الرقم الجامعي / Student ID',
              icon: Icons.badge_outlined,
              keyboard: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'أدخل الرقم الجامعي';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            _field(
              controller: _passCtrl,
              label: 'كلمة المرور / Password',
              icon: Icons.lock_outline,
              obscure: _hidePass,
              suffix: IconButton(
                icon: Icon(
                  _hidePass ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.cyberTeal.withOpacity(0.6),
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _hidePass = !_hidePass);
                },
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'كلمة المرور 6 أحرف على الأقل';
                }
                return null;
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark
                      ? AppColors.aquaFoam
                      : AppColors.cyberTeal,
                  foregroundColor: _isDark
                      ? AppColors.cyberTeal
                      : AppColors.aquaFoam,
                  disabledBackgroundColor: mainColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _isDark
                              ? AppColors.cyberTeal
                              : AppColors.aquaFoam,
                        ),
                      )
                    : const Text(
                        'تسجيل الدخول  |  Sign in',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(
      Color color, {
      double width = 1.0,
    }) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    // حقول الإدخال تبقى بيضاء بالوضعين عشان النص يبقى واضح
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(
        color: AppColors.cyberTeal,
      ),
      cursorColor: AppColors.cyberTeal,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.cyberTeal.withOpacity(0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.cyberTeal.withOpacity(0.6),
          size: 20,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: border(AppColors.cyberTeal.withOpacity(0.2)),
        focusedBorder: border(AppColors.cyberTeal, width: 1.5),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, width: 1.5),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}