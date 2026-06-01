import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:wazni/models/entry_model.dart';
import 'package:wazni/models/user_model.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _codeCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _addChallenge(String myUid, List<String> existing) async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    final me = context.read<WazniUserProvider>().user!;
    if (code == me.code) {
      _err('هذا كودك الشخصي!'); return;
    }
    setState(() => _adding = true);
    try {
      final fUid = await WazniFirebaseService.instance.uidFromCode(code);
      if (fUid == null) { _err('الكود غير موجود'); return; }
      if (existing.contains(fUid)) { _err('أنتِ في تحدٍ معها مسبقاً'); return; }
      await WazniFirebaseService.instance.addChallenge(myUid, fUid);
      await context.read<WazniUserProvider>().refresh();
      _codeCtrl.clear();
    } catch (e) {
      _err('حدث خطأ، حاولي مرة أخرى');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: GoogleFonts.tajawal()), backgroundColor: WazniTheme.red),
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;
    if (user == null) return const SizedBox();

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Add challenge card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🤝 تحدي جديد', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('أدخلي كود صديقتك لبدء التنافس', style: GoogleFonts.tajawal(color: WazniTheme.inkMuted, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'XXXXXX',
                      counterText: '',
                    ),
                  )),
                  const SizedBox(width: 10),
                  _adding
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _addChallenge(user.uid, user.challenges),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 50)),
                          child: Text('ابدئي 🚀', style: GoogleFonts.tajawal()),
                        ),
                ]),
              ]),
            ),
          ),

          const SizedBox(height: 8),

          // Challenges list
          if (user.challenges.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(children: [
                  const Text('🏆', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text('لا يوجد تحديات بعد', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('أضيفي كود صديقتك لتبدأي المنافسة!',
                    style: GoogleFonts.tajawal(color: WazniTheme.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            )
          else
            ...user.challenges.map((fUid) => _ChallengeCard(myUser: user, friendUid: fUid)),
        ]),
      );
  }
}

// ── Challenge Card ────────────────────────────────────────────────────────────
class _ChallengeCard extends StatefulWidget {
  final WazniUser myUser;
  final String friendUid;

  const _ChallengeCard({required this.myUser, required this.friendUid});

  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  WazniUser? _friend;
  List<WeightEntry> _myData   = [];
  List<WeightEntry> _fData    = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final friend = await WazniFirebaseService.instance.getUser(widget.friendUid);
    final myData = await WazniFirebaseService.instance.getEntries(widget.myUser.uid);
    final fData  = await WazniFirebaseService.instance.getEntries(widget.friendUid);
    if (mounted) setState(() {
      _friend  = friend;
      _myData  = myData;
      _fData   = fData;
      _loading = false;
    });
  }

  Future<void> _remove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إلغاء التحدي', style: GoogleFonts.tajawal()),
        content: Text('هل تريدين إلغاء هذا التحدي؟', style: GoogleFonts.tajawal()),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context,false), child: Text('لا', style: GoogleFonts.tajawal())),
          TextButton(onPressed: ()=>Navigator.pop(context,true),  child: Text('نعم', style: GoogleFonts.tajawal(color: WazniTheme.red))),
        ],
      ),
    );
    if (ok == true) {
      await WazniFirebaseService.instance.removeChallenge(widget.myUser.uid, widget.friendUid);
      if (mounted) context.read<WazniUserProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
    if (_friend == null) return const SizedBox();

    final myW   = _myData.map((e)=>e.weight).toList();
    final fW    = _fData.map((e)=>e.weight).toList();
    final myLast  = myW.isNotEmpty ? myW.last : null;
    final fLast   = fW.isNotEmpty  ? fW.last  : null;
    final myStart = widget.myUser.startWeight ?? (myW.isNotEmpty ? myW.first : null);
    final fStart  = _friend!.startWeight ?? (fW.isNotEmpty ? fW.first : null);
    final myLoss  = myStart != null && myLast != null ? myStart - myLast : 0.0;
    final fLoss   = fStart  != null && fLast  != null ? fStart  - fLast  : 0.0;
    int? myPct, fPct;
    if (widget.myUser.goalWeight != null && myStart != null && myLast != null && myStart > widget.myUser.goalWeight!) {
      myPct = ((myStart - myLast) / (myStart - widget.myUser.goalWeight!) * 100).clamp(0,100).round();
    }
    if (_friend!.goalWeight != null && fStart != null && fLast != null && fStart > _friend!.goalWeight!) {
      fPct = ((fStart - fLast) / (fStart - _friend!.goalWeight!) * 100).clamp(0,100).round();
    }
    final iWin = (myPct != null && fPct != null) ? myPct >= fPct : myLoss >= fLoss;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('⚔️ ${_friend!.name}', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14))),
            TextButton(
              onPressed: _remove,
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: WazniTheme.red, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 12),

          // Players comparison
          Row(children: [
            Expanded(child: _playerBox(widget.myUser.initials, widget.myUser.name.split(' ').first, myLoss, myPct, iWin, WazniTheme.brand)),
            const SizedBox(width: 10),
            Expanded(child: _playerBox(_friend!.initials, _friend!.name.split(' ').first, fLoss, fPct, !iWin, WazniTheme.orange)),
          ]),

          // Compare chart
          if (_myData.isNotEmpty && _fData.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: _CompareChart(myData: _myData, fData: _fData, myName: widget.myUser.name, fName: _friend!.name),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _playerBox(String ini, String name, double loss, int? pct, bool winning, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: winning ? WazniTheme.green : WazniTheme.border, width: winning ? 2 : 1),
    ),
    child: Column(children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Text(ini, style: GoogleFonts.tajawal(color: color, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 6),
      Text(name, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 12)),
      Text('نقص: ${loss.toStringAsFixed(1)} كغ', style: GoogleFonts.tajawal(color: WazniTheme.green, fontSize: 11)),
      if (pct != null) Text('إنجاز: $pct%', style: GoogleFonts.tajawal(fontSize: 11, color: WazniTheme.inkMuted)),
      if (winning) const Text('🏆', style: TextStyle(fontSize: 14)),
    ]),
  );
}

// ── Compare Line Chart ────────────────────────────────────────────────────────
class _CompareChart extends StatelessWidget {
  final List<WeightEntry> myData, fData;
  final String myName, fName;
  const _CompareChart({required this.myData, required this.fData, required this.myName, required this.fName});

  @override
  Widget build(BuildContext context) {
    final allW = [...myData.map((e)=>e.weight), ...fData.map((e)=>e.weight)];
    final lo = allW.reduce((a,b)=>a<b?a:b) - 1;
    final hi = allW.reduce((a,b)=>a>b?a:b) + 1;

    return LineChart(LineChartData(
      minY: lo, maxY: hi,
      lineBarsData: [
        LineChartBarData(
          spots: myData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
          isCurved: true, color: WazniTheme.brandLight, barWidth: 2.5, dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: WazniTheme.brandLight.withValues(alpha: 0.1)),
        ),
        LineChartBarData(
          spots: fData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
          isCurved: true, color: WazniTheme.orange, barWidth: 2.5, dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: WazniTheme.orange.withValues(alpha: 0.1)),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= myData.length) return const SizedBox();
            return Text(myData[i].label, style: GoogleFonts.tajawal(fontSize: 8, color: WazniTheme.inkMuted));
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 32,
          getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: GoogleFonts.tajawal(fontSize: 9, color: WazniTheme.inkMuted)),
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => FlLine(color: WazniTheme.border, strokeWidth: 0.5),
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(show: false),
    ));
  }
}
