import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wazni/main.dart';
import 'package:wazni/screens/splash_screen.dart';
import 'package:wazni/screens/auth_screen.dart';
import 'package:wazni/screens/home_screen.dart';
import 'package:wazni/screens/workout_timer_screen.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() { _sub.cancel(); super.dispose(); }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  refreshListenable: _GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final path = state.uri.path;

    if (path == '/splash') return null;

    if (user == null && path != '/auth') return '/auth';
    if (user != null && path == '/auth') return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const WazniSplashScreen()),
    GoRoute(path: '/auth',   builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/workout',
      builder: (_, state) => WorkoutTimerScreen(
        exerciseIndex: (state.extra as int? ?? 0),
      ),
    ),
  ],
);
