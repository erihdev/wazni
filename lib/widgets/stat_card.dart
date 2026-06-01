import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wazni/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: WazniTheme.border),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.tajawal(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: valueColor ?? WazniTheme.ink,
        )),
        Text(unit, style: GoogleFonts.tajawal(fontSize: 10, color: WazniTheme.inkFaint)),
      ],
    ),
  );
}
