import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:wazni/models/entry_model.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';
import 'package:wazni/widgets/stat_card.dart';

class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  final _labelCtrl  = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _add(String uid) async {
    final label  = _labelCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text);
    if (label.isEmpty || weight == null || weight < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بيانات صحيحة')),
      );
      return;
    }
    await WazniFirebaseService.instance.addEntry(uid, WeightEntry(
      label: label, weight: weight, ts: DateTime.now().millisecondsSinceEpoch,
    ));
    _labelCtrl.clear();
    _weightCtrl.clear();
  }

  Future<void> _remove(String uid, int i) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حذف', style: GoogleFonts.tajawal()),
        content: Text('هل تريدين حذف هذه القراءة؟', style: GoogleFonts.tajawal()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء', style: GoogleFonts.tajawal())),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: Text('حذف', style: GoogleFonts.tajawal(color: WazniTheme.red))),
        ],
      ),
    );
    if (confirm == true) await WazniFirebaseService.instance.removeEntry(uid, i);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;
    if (user == null) return const SizedBox();

    return StreamBuilder<List<WeightEntry>>(
      stream: WazniFirebaseService.instance.entriesStream(user.uid),
      builder: (ctx, snap) {
        final entries = snap.data ?? [];
        final weights = entries.map((e) => e.weight).toList();
        final startW  = user.startWeight ?? (weights.isNotEmpty ? weights.first : null);
        final last    = weights.isNotEmpty ? weights.last : null;
        final loss    = startW != null && last != null ? startW - last : null;
        final goal    = user.goalWeight;
        int? pct;
        if (goal != null && startW != null && last != null && startW > goal) {
          pct = ((startW - last) / (startW - goal) * 100).clamp(0, 100).round();
        }

        return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(delegate: SliverChildListDelegate([

                  // Stats
                  Row(children: [
                    Expanded(child: StatCard(label: 'الحالي', value: last?.toStringAsFixed(1) ?? '—', unit: 'كغ')),
                    const SizedBox(width: 8),
                    Expanded(child: StatCard(
                      label: 'النقص',
                      value: loss != null ? '${loss >= 0 ? '-' : '+'}${loss.abs().toStringAsFixed(1)}' : '—',
                      unit: 'كغ', valueColor: WazniTheme.green,
                    )),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: StatCard(label: 'الهدف', value: goal?.toStringAsFixed(1) ?? '—', unit: 'كغ', valueColor: WazniTheme.brand)),
                    const SizedBox(width: 8),
                    Expanded(child: StatCard(label: 'الإنجاز', value: pct != null ? '$pct' : '—', unit: '%', valueColor: const Color(0xFF639922))),
                  ]),

                  const SizedBox(height: 16),

                  // Add entry card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(children: [
                            Expanded(child: TextField(
                              controller: _labelCtrl,
                              decoration: const InputDecoration(labelText: 'الفترة / التاريخ', hintText: 'أسبوع 1'),
                            )),
                            const SizedBox(width: 10),
                            SizedBox(width: 110, child: TextField(
                              controller: _weightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'الوزن (كغ)', hintText: '85.0'),
                            )),
                            const SizedBox(width: 10),
                            FloatingActionButton.small(
                              onPressed: () => _add(user.uid),
                              backgroundColor: WazniTheme.brand,
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Chart
                  if (entries.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legend(),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: _buildChart(entries, goal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Entries list
                  if (entries.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('السجل', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
                        TextButton(
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('مسح الكل', style: GoogleFonts.tajawal()),
                                content: Text('هل تريدين مسح جميع البيانات؟', style: GoogleFonts.tajawal()),
                                actions: [
                                  TextButton(onPressed: ()=>Navigator.pop(context,false), child: Text('إلغاء', style: GoogleFonts.tajawal())),
                                  TextButton(onPressed: ()=>Navigator.pop(context,true),  child: Text('مسح', style: GoogleFonts.tajawal(color: WazniTheme.red))),
                                ],
                              ),
                            );
                            if (ok==true) WazniFirebaseService.instance.clearEntries(user.uid);
                          },
                          child: Text('مسح الكل', style: GoogleFonts.tajawal(color: WazniTheme.red, fontSize: 12)),
                        ),
                      ],
                    ),
                    ...entries.reversed.toList().asMap().entries.map((e) {
                      final i    = entries.length - 1 - e.key;
                      final ent  = e.value;
                      final prev = i > 0 ? entries[i-1].weight : null;
                      final diff = prev != null ? ent.weight - prev : null;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(ent.label, style: GoogleFonts.tajawal(color: WazniTheme.inkMuted)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${ent.weight.toStringAsFixed(1)} كغ',
                              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                            if (diff != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${diff <= 0 ? '▼' : '▲'} ${diff.abs().toStringAsFixed(1)}',
                                style: GoogleFonts.tajawal(
                                  fontSize: 11,
                                  color: diff <= 0 ? WazniTheme.green : WazniTheme.red,
                                ),
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: WazniTheme.inkFaint),
                              onPressed: () => _remove(user.uid, i),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                ])),
              ),
            ],
          );
      },
    );
  }

  Widget _legend() => Row(children: [
    _dot(WazniTheme.brandLight, 'وزني'),
    const SizedBox(width: 12),
    _dot(WazniTheme.orange, 'أعلى وزن'),
    const SizedBox(width: 12),
    Row(children: [
      SizedBox(width: 18, child: Divider(color: WazniTheme.green, thickness: 2, indent: 0, endIndent: 0)),
      const SizedBox(width: 4),
      Text('الهدف', style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted)),
    ]),
  ]);

  Widget _dot(Color c, String label) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted)),
  ]);

  Widget _buildChart(List<WeightEntry> entries, double? goal) {
    final weights = entries.map((e) => e.weight).toList();
    final maxW = weights.reduce((a,b) => a>b?a:b);
    final minW = weights.reduce((a,b) => a<b?a:b);
    final allVals = [...weights, if(goal!=null) goal];
    final lo = allVals.reduce((a,b)=>a<b?a:b) - 2;
    final hi = allVals.reduce((a,b)=>a>b?a:b) + 2;

    return BarChart(BarChartData(
      minY: lo, maxY: hi,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= entries.length) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(entries[i].label, style: GoogleFonts.tajawal(fontSize: 9, color: WazniTheme.inkMuted)),
            );
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: GoogleFonts.tajawal(fontSize: 9, color: WazniTheme.inkMuted)),
        )),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => FlLine(color: WazniTheme.border, strokeWidth: 0.5),
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: goal != null ? ExtraLinesData(horizontalLines: [
        HorizontalLine(y: goal, color: WazniTheme.green, strokeWidth: 1.5,
          dashArray: [6, 4],
          label: HorizontalLineLabel(show: true, labelResolver: (_) => 'هدف', style: GoogleFonts.tajawal(color: WazniTheme.green, fontSize: 10)),
        ),
      ]) : null,
      barGroups: entries.asMap().entries.map((e) {
        final isMax = e.value.weight == maxW;
        return BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(
            toY: e.value.weight,
            fromY: lo,
            color: isMax ? WazniTheme.orange : WazniTheme.brandLight,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          )],
        );
      }).toList(),
    ));
  }
}
