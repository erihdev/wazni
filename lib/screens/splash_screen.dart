import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wazni/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class WazniSplashScreen extends StatefulWidget {
  const WazniSplashScreen({super.key});

  @override
  State<WazniSplashScreen> createState() => _WazniSplashScreenState();
}

class _WazniSplashScreenState extends State<WazniSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      context.go(user != null ? '/home' : '/auth');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: WazniTheme.brand,
    body: FadeTransition(
      opacity: _fade,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('⚖️', style: TextStyle(fontSize: 44))),
            ),
            const SizedBox(height: 20),
            Text('وزني', style: GoogleFonts.tajawal(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 6),
            Text('by erihdev', style: GoogleFonts.tajawal(
              color: Colors.white60, fontSize: 13, letterSpacing: 1,
            )),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white60, strokeWidth: 2,
            ),
          ],
        ),
      ),
    ),
  );
}
