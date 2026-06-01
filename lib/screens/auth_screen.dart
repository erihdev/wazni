import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = false;

  // Login
  final _lEmail = TextEditingController();
  final _lPass  = TextEditingController();
  bool  _lPassVisible = false;

  // Register
  final _rName  = TextEditingController();
  final _rEmail = TextEditingController();
  final _rPass  = TextEditingController();
  final _rStart = TextEditingController();
  final _rGoal  = TextEditingController();
  bool  _rPassVisible = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_lEmail,_lPass,_rName,_rEmail,_rPass,_rStart,_rGoal]) c.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: WazniTheme.red),
    );
  }

  Future<void> _login() async {
    final email = _lEmail.text.trim();
    final pass  = _lPass.text;
    if (email.isEmpty || pass.isEmpty) { _showError('يرجى ملء جميع الحقول'); return; }
    setState(() => _loading = true);
    try {
      await WazniFirebaseService.instance.signIn(email, pass);
      if (mounted) context.go('/home');
    } catch (e) {
      _showError(_authError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final name  = _rName.text.trim();
    final email = _rEmail.text.trim();
    final pass  = _rPass.text;
    final start = double.tryParse(_rStart.text);
    final goal  = double.tryParse(_rGoal.text);
    if (name.isEmpty || email.isEmpty || pass.isEmpty) { _showError('يرجى ملء الحقول المطلوبة'); return; }
    if (pass.length < 6) { _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل'); return; }
    setState(() => _loading = true);
    try {
      await WazniFirebaseService.instance.register(
        name: name, email: email, password: pass,
        startWeight: start, goalWeight: goal,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      _showError(_authError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authError(String e) {
    if (e.contains('user-not-found') || e.contains('invalid-credential')) return 'البريد أو كلمة المرور غير صحيحة';
    if (e.contains('wrong-password'))    return 'كلمة المرور غير صحيحة';
    if (e.contains('email-already'))     return 'هذا البريد مسجّل مسبقاً';
    if (e.contains('invalid-email'))     return 'صيغة البريد غير صحيحة';
    if (e.contains('weak-password'))     return 'كلمة المرور ضعيفة جداً';
    return 'حدث خطأ، حاولي مرة أخرى';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Hero
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: WazniTheme.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 14),
              Text('وزني', style: GoogleFonts.tajawal(
                fontSize: 28, fontWeight: FontWeight.w800, color: WazniTheme.brand,
              )),
              const SizedBox(height: 4),
              Text('تتبعي وزنك وتنافسي مع صديقاتك',
                style: GoogleFonts.tajawal(color: WazniTheme.inkMuted, fontSize: 14)),
              const SizedBox(height: 30),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: WazniTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: WazniTheme.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: WazniTheme.inkMuted,
                  labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 14),
                  dividerColor: Colors.transparent,
                  tabs: const [Tab(text: 'تسجيل الدخول'), Tab(text: 'حساب جديد')],
                ),
              ),
              const SizedBox(height: 24),

              // Forms
              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabs,
                  children: [_loginForm(), _registerForm()],
                ),
              ),
              const SizedBox(height: 20),

              // Submit
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _tabs.index == 0 ? _login() : _register(),
                      child: Text(_tabs.index == 0 ? 'دخول' : 'إنشاء الحساب'),
                    ),

              const SizedBox(height: 20),
              Text('by erihdev', style: GoogleFonts.tajawal(
                color: WazniTheme.inkFaint, fontSize: 11,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm() => Column(
    children: [
      _field(controller: _lEmail, label: 'البريد الإلكتروني', hint: 'example@email.com', keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _field(
        controller: _lPass, label: 'كلمة المرور', hint: '••••••••',
        obscure: !_lPassVisible,
        suffix: IconButton(
          icon: Icon(_lPassVisible ? Icons.visibility_off : Icons.visibility, color: WazniTheme.inkMuted),
          onPressed: () => setState(() => _lPassVisible = !_lPassVisible),
        ),
      ),
    ],
  );

  Widget _registerForm() => SingleChildScrollView(
    child: Column(
      children: [
        _field(controller: _rName,  label: 'الاسم *', hint: 'اسمك'),
        const SizedBox(height: 10),
        _field(controller: _rEmail, label: 'البريد *', hint: 'example@email.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field(
          controller: _rPass, label: 'كلمة المرور * (6+)', hint: '••••••••',
          obscure: !_rPassVisible,
          suffix: IconButton(
            icon: Icon(_rPassVisible ? Icons.visibility_off : Icons.visibility, color: WazniTheme.inkMuted),
            onPressed: () => setState(() => _rPassVisible = !_rPassVisible),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _field(controller: _rStart, label: 'الوزن الابتدائي (كغ)', hint: '90', keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _field(controller: _rGoal,  label: 'الوزن الهدف (كغ)',    hint: '75', keyboardType: TextInputType.number)),
        ]),
      ],
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    textDirection: TextDirection.ltr,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
    ),
  );
}
