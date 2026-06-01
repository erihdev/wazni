import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;
    if (user == null) return const SizedBox();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<Map<String, bool>>(
      stream: WazniFirebaseService.instance.prayersStream(user.uid, today),
      builder: (ctx, snap) {
        final prayed = snap.data ?? {};
        final count  = _prayers.where((p) => prayed[p.key] == true).length;
        final pts    = count * 20 + (count == 5 ? 50 : 0);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Daily header card
                  _DailySummaryCard(count: count, pts: pts),

                  const SizedBox(height: 16),

                  // Prayer cards
                  ..._prayers.map((p) {
                    final done = prayed[p.key] == true;
                    return _PrayerCard(
                      prayer: p,
                      done: done,
                      onTap: () async {
                        await WazniFirebaseService.instance.togglePrayer(
                          uid: user.uid,
                          date: today,
                          prayerKey: p.key,
                          currentValue: done,
                          pointsDelta: done ? -20 : 20,
                          wasAllFive: count == 5,
                          willBeAllFive: !done && count == 4,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // Points rules card
                  _PointsRulesCard(),

                  // Weekly history
                  const SizedBox(height: 8),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: WazniFirebaseService.instance.prayerHistoryStream(user.uid),
                    builder: (ctx2, snap2) {
                      final history = snap2.data ?? [];
                      if (history.isEmpty) return const SizedBox();
                      return _WeeklyHistoryCard(history: history);
                    },
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Data ───────────────────────────────────────────────────────────────────

class _PrayerInfo {
  final String key;
  final String nameAr;
  final String time;
  final String emoji;
  final Color color;
  const _PrayerInfo(this.key, this.nameAr, this.time, this.emoji, this.color);
}

const _prayers = [
  _PrayerInfo('fajr',   'الفجر',   'قبل شروق الشمس', '🌙', Color(0xFF6C63FF)),
  _PrayerInfo('dhuhr',  'الظهر',   'منتصف النهار',    '☀️', Color(0xFFFA8231)),
  _PrayerInfo('asr',    'العصر',   'بعد الظهر',       '🌤️', Color(0xFF4facfe)),
  _PrayerInfo('maghrib','المغرب',  'عند الغروب',      '🌅', Color(0xFFFF6B9D)),
  _PrayerInfo('isha',   'العشاء',  'بعد الغروب',      '🌙', Color(0xFF43E97B)),
];

// ─── Widgets ────────────────────────────────────────────────────────────────

class _DailySummaryCard extends StatelessWidget {
  final int count;
  final int pts;
  const _DailySummaryCard({required this.count, required this.pts});

  @override
  Widget build(BuildContext context) {
    final allDone = count == 5;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allDone
              ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
              : [WazniTheme.brand, WazniTheme.brandLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (allDone ? const Color(0xFF43E97B) : WazniTheme.brand)
                .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allDone ? '🎉 أكملتِ صلواتكِ!' : 'صلوات اليوم',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                    style: GoogleFonts.tajawal(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '$pts',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      'نقطة ⭐',
                      style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: List.generate(5, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8,
                decoration: BoxDecoration(
                  color: i < count
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text(
            '$count من 5 صلوات${count == 5 ? ' ✅' : ''}',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final _PrayerInfo prayer;
  final bool done;
  final VoidCallback onTap;
  const _PrayerCard({required this.prayer, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: done
            ? prayer.color.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done ? prayer.color.withValues(alpha: 0.4) : WazniTheme.border,
          width: done ? 1.5 : 1,
        ),
        boxShadow: done
            ? [BoxShadow(color: prayer.color.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: prayer.color.withValues(alpha: done ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(prayer.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.nameAr,
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: done ? prayer.color : WazniTheme.ink,
                        ),
                      ),
                      Text(
                        prayer.time,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: WazniTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Points tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: WazniTheme.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+20 ⭐',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: WazniTheme.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: done ? prayer.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: done ? prayer.color : WazniTheme.border,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PointsRulesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: WazniTheme.brand.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: WazniTheme.brand.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💫 نظام النقاط',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 15, color: WazniTheme.brand),
            ),
            const SizedBox(height: 10),
            _rule('⭐', '20 نقطة', 'لكل صلاة تُصلّينها'),
            _rule('🎁', '+50 نقطة', 'مكافأة عند إكمال الصلوات الخمس'),
            _rule('🏆', '100 نقطة يومياً', 'الحد الأقصى في اليوم الكامل'),
          ],
        ),
      ),
    );
  }

  Widget _rule(String icon, String pts, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(pts, style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 13, color: WazniTheme.orange)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(desc, style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.inkMuted)),
        ),
      ],
    ),
  );
}

class _WeeklyHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _WeeklyHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 سجل الأسبوع',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...history.take(7).map((day) {
              final date = day['date'] as String? ?? '';
              final prayers = Map<String, bool>.from(day['prayers'] as Map? ?? {});
              final count = _prayers.where((p) => prayers[p.key] == true).length;
              DateTime? dt;
              try { dt = DateTime.parse(date); } catch (_) {}
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        dt != null ? DateFormat('EEE d/M', 'ar').format(dt) : date,
                        style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.inkMuted),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: _prayers.map((p) {
                          final done = prayers[p.key] == true;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 28,
                              decoration: BoxDecoration(
                                color: done
                                    ? p.color.withValues(alpha: 0.15)
                                    : WazniTheme.border.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: done ? p.color.withValues(alpha: 0.4) : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  done ? '✓' : '·',
                                  style: TextStyle(
                                    fontSize: done ? 14 : 18,
                                    color: done ? p.color : WazniTheme.inkFaint,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count/5',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: count == 5 ? WazniTheme.green : WazniTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
