import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WazniTheme {
  // ─── Brand Colors ─────────────────────────────────────────────
  static const Color brand      = Color(0xFF185FA5);
  static const Color brandLight = Color(0xFF378ADD);
  static const Color brandDark  = Color(0xFF0D3D6B);
  static const Color green      = Color(0xFF1D9E75);
  static const Color orange     = Color(0xFFD85A30);
  static const Color red        = Color(0xFFE24B4A);
  static const Color surface    = Color(0xFFF5F5F3);
  static const Color ink        = Color(0xFF1A1A1A);
  static const Color inkMuted   = Color(0xFF666666);
  static const Color inkFaint   = Color(0xFF999999);
  static const Color border     = Color(0xFFE0E0E0);

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: brand,
      surface: surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: surface,

      textTheme: GoogleFonts.tajawalTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: ink, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 26),
          headlineMedium:TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 22),
          headlineSmall: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 18),
          titleLarge:    TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 16),
          titleMedium:   TextStyle(color: ink, fontWeight: FontWeight.w600, fontSize: 14),
          titleSmall:    TextStyle(color: inkMuted, fontWeight: FontWeight.w500, fontSize: 13),
          bodyLarge:     TextStyle(color: ink, fontSize: 15, height: 1.6),
          bodyMedium:    TextStyle(color: inkMuted, fontSize: 13, height: 1.5),
          bodySmall:     TextStyle(color: inkMuted, fontSize: 11),
          labelLarge:    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          side: const BorderSide(color: brand),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red),
        ),
        labelStyle: GoogleFonts.tajawal(color: inkMuted, fontSize: 14),
        hintStyle: GoogleFonts.tajawal(color: inkFaint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: brand,
        unselectedItemColor: inkFaint,
        selectedLabelStyle: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 11),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.tajawal(fontSize: 13),
      ),
    );
  }
}
