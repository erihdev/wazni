import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wazni/models/inbody_model.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';
import 'package:intl/intl.dart';

class InBodyScreen extends StatefulWidget {
  const InBodyScreen({super.key});

  @override
  State<InBodyScreen> createState() => _InBodyScreenState();
}

class _InBodyScreenState extends State<InBodyScreen> {
  final _weightCtrl    = TextEditingController();
  final _fatPctCtrl    = TextEditingController();
  final _fatKgCtrl     = TextEditingController();
  final _muscleCtrl    = TextEditingController();
  final _waterCtrl     = TextEditingController();
  final _visceralCtrl  = TextEditingController();
  final _bmiCtrl       = TextEditingController();
  final _boneCtrl      = TextEditingController();
  final _scoreCtrl     = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_weightCtrl, _fatPctCtrl, _fatKgCtrl, _muscleCtrl,
                     _waterCtrl, _visceralCtrl, _bmiCtrl, _boneCtrl, _scoreCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(String uid) async {
    final weight   = double.tryParse(_weightCtrl.text);
    final fatPct   = double.tryParse(_fatPctCtrl.text);
    final fatKg    = double.tryParse(_fatKgCtrl.text);
    final muscle   = double.tryParse(_muscleCtrl.text);
    final water    = double.tryParse(_waterCtrl.text);
    final visceral = double.tryParse(_visceralCtrl.text);
    final bmi      = double.tryParse(_bmiCtrl.text);
    final bone     = double.tryParse(_boneCtrl.text);
    final score    = int.tryParse(_scoreCtrl.text);

    if (weight == null || fatPct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الوزن ونسبة الدهون على الأقل')),
      );
      return;
    }

    setState(() => _saving = true);
    await WazniFirebaseService.instance.addInBody(
      uid,
      InBodyRecord(
        weight: weight,
        fatPct: fatPct,
        fatKg: fatKg ?? 0,
        muscleMass: muscle ?? 0,
        waterPct: water ?? 0,
        visceralFat: visceral ?? 0,
        bmi: bmi ?? 0,
        boneMass: bone ?? 0,
        score: score ?? 0,
        ts: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    for (final c in [_weightCtrl, _fatPctCtrl, _fatKgCtrl, _muscleCtrl,
                     _waterCtrl, _visceralCtrl, _bmiCtrl, _boneCtrl, _scoreCtrl]) {
      c.clear();
    }
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ نتيجة InBody')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;
    if (user == null) return const SizedBox();

    return StreamBuilder<List<InBodyRecord>>(
      stream: WazniFirebaseService.instance.inBodyStream(user.uid),
      builder: (ctx, snap) {
        final records = snap.data ?? [];
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Latest snapshot
                  if (records.isNotEmpty) ...[
                    _sectionTitle('🧬 آخر نتيجة InBody'),
                    _buildSnapshot(records.last, records.length > 1 ? records[records.length - 2] : null),
                  ],

                  // Input form
                  _sectionTitle('➕ تسجيل نتيجة جديدة'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _grid([
                            _field(_weightCtrl,   '⚖️ الوزن الكلي (كيلو)',     '45.5'),
                            _field(_fatPctCtrl,   '🔴 نسبة الدهون (%)',         '28.5'),
                            _field(_fatKgCtrl,    '🟠 كتلة الدهون (كيلو)',      '12.8'),
                            _field(_muscleCtrl,   '💪 كتلة العضلات (كيلو)',    '17.2'),
                            _field(_waterCtrl,    '💧 نسبة الماء (%)',           '52.3'),
                            _field(_visceralCtrl, '⚠️ الدهون الحشوية (درجة)',   '4'),
                            _field(_bmiCtrl,      '📊 مؤشر BMI',               '22.5'),
                            _field(_boneCtrl,     '🦴 الكتلة العظمية (كيلو)',   '1.8'),
                            _field(_scoreCtrl,    '🎯 نقاط InBody',             '75'),
                          ]),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: _saving ? null : () => _save(user.uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WazniTheme.green,
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('💾 حفظ النتيجة',
                                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Reference ranges
                  _sectionTitle('📌 المعدلات الطبيعية (10–12 سنة)'),
                  _buildReferenceTable(),

                  // History
                  if (records.length > 1) ...[
                    _sectionTitle('📈 سجل القياسات'),
                    _buildHistoryTable(records),
                  ],

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSnapshot(InBodyRecord r, InBodyRecord? prev) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score circle
            if (r.score > 0) ...[
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: CircularProgressIndicator(
                        value: r.score / 100,
                        strokeWidth: 8,
                        backgroundColor: WazniTheme.border,
                        color: r.score >= 80 ? WazniTheme.green : r.score >= 60 ? WazniTheme.orange : WazniTheme.red,
                      ),
                    ),
                    Column(
                      children: [
                        Text('${r.score}', style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('InBody', style: GoogleFonts.tajawal(fontSize: 9, color: WazniTheme.inkMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _metric('⚖️', 'الوزن',   '${r.weight}', 'كيلو', _diff(prev?.weight, r.weight, false)),
                _metric('🔴', 'الدهون',  '${r.fatPct}%', '',     _diff(prev?.fatPct, r.fatPct, false)),
                _metric('💪', 'العضلات', '${r.muscleMass}', 'كيلو', _diff(prev?.muscleMass, r.muscleMass, true)),
                _metric('📊', 'BMI',     '${r.bmi}', '',         null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _diff(double? prev, double curr, bool higherIsBetter) {
    if (prev == null) return null;
    final d = curr - prev;
    if (d.abs() < 0.01) return null;
    final good = higherIsBetter ? d > 0 : d < 0;
    return '${good ? '▲' : '▼'} ${d.abs().toStringAsFixed(1)}';
  }

  Widget _metric(String icon, String label, String value, String unit, String? diff) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WazniTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WazniTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon $label', style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '$value${unit.isNotEmpty ? ' $unit' : ''}',
            style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          if (diff != null)
            Text(
              diff,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: diff.startsWith('▲') ? WazniTheme.green : WazniTheme.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReferenceTable() {
    final rows = [
      ('الوزن (كيلو)',     '25–45',  '45–55',   '>55'),
      ('نسبة الدهون (%)', '15–25',  '25–32',   '>32'),
      ('كتلة العضلات',    '14–20',  '—',       '<14'),
      ('BMI',             '16–22',  '22–25',   '>25'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _tableHeader('القياس')),
              Expanded(child: _tableHeader('✅ ممتاز')),
              Expanded(child: _tableHeader('⚠️ طبيعي')),
              Expanded(child: _tableHeader('🔴 مرتفع')),
            ]),
            const Divider(),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: Text(r.$1, style: GoogleFonts.tajawal(fontSize: 12))),
                Expanded(child: Text(r.$2, style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.green))),
                Expanded(child: Text(r.$3, style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.orange))),
                Expanded(child: Text(r.$4, style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.red))),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String t) => Text(
    t,
    style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w800, color: WazniTheme.inkMuted),
  );

  Widget _buildHistoryTable(List<InBodyRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: records.reversed.take(6).map((r) {
            final date = DateFormat('dd/MM').format(
              DateTime.fromMillisecondsSinceEpoch(r.ts),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                SizedBox(
                  width: 44,
                  child: Text(date, style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted)),
                ),
                Expanded(child: Text('${r.weight} كيلو', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700))),
                Expanded(child: Text('${r.fatPct}% دهون', style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.red))),
                Expanded(child: Text('${r.muscleMass} عضلات', style: GoogleFonts.tajawal(fontSize: 12, color: WazniTheme.green))),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Text(t, style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w800)),
  );

  Widget _grid(List<Widget> children) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: children,
  );

  Widget _field(TextEditingController ctrl, String label, String hint) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 72) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700, color: WazniTheme.inkMuted)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
