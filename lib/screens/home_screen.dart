import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';
import 'package:wazni/screens/my_progress_screen.dart';
import 'package:wazni/screens/exercises_screen.dart';
import 'package:wazni/screens/diet_screen.dart';
import 'package:wazni/screens/inbody_screen.dart';
import 'package:wazni/screens/prayers_screen.dart';
import 'package:wazni/screens/challenge_screen.dart';
import 'package:wazni/screens/my_code_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    MyProgressScreen(),
    ExercisesScreen(),
    DietScreen(),
    InBodyScreen(),
    PrayersScreen(),
    ChallengeScreen(),
    MyCodeScreen(),
  ];

  Future<void> _logout() async {
    await WazniFirebaseService.instance.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('⚖️', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Wazni وزني', style: GoogleFonts.tajawal(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                Text('by erihdev', style: GoogleFonts.tajawal(
                  color: Colors.white60, fontSize: 9, letterSpacing: 0.5,
                )),
              ],
            ),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: Row(
                children: [
                  // مؤشر الاتصال
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                      color: WazniTheme.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showUserMenu(context),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        user.initials,
                        style: GoogleFonts.tajawal(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),      label: 'وزني'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded),  label: 'تمارين'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'تغذية'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_weight_rounded),  label: 'InBody'),
          BottomNavigationBarItem(icon: Icon(Icons.mosque_rounded),          label: 'صلواتي'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded),    label: 'التحدي'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded),         label: 'كودي'),
        ],
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    final user = context.read<WazniUserProvider>().user;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: WazniTheme.brand.withValues(alpha: 0.12),
                child: Text(user?.initials ?? '',
                  style: GoogleFonts.tajawal(color: WazniTheme.brand, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(user?.name ?? '', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user?.email ?? '', style: GoogleFonts.tajawal(color: WazniTheme.inkMuted, fontSize: 13)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: WazniTheme.red),
                title: Text('تسجيل الخروج', style: GoogleFonts.tajawal(color: WazniTheme.red)),
                onTap: () { Navigator.pop(context); _logout(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
