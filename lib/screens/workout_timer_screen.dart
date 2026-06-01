import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wazni/data/exercises_data.dart';
import 'package:wazni/models/workout_model.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final int exerciseIndex;
  const WorkoutTimerScreen({super.key, required this.exerciseIndex});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen>
    with TickerProviderStateMixin {
  late final Exercise _ex;
  late AnimationController _progressCtrl;

  int _currentRound = 0;
  int _secondsLeft = 0;
  bool _isResting = false;
  bool _isRunning = false;
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ex = kExercises[widget.exerciseIndex];
    _secondsLeft = _ex.duration;
    _progressCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: _ex.duration),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _progressCtrl.forward(from: 1 - _secondsLeft / _totalSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _pause() {
    _timer?.cancel();
    _progressCtrl.stop();
    setState(() => _isRunning = false);
  }

  int get _totalSeconds => _isResting ? _ex.rest : _ex.duration;

  void _tick(Timer t) {
    if (_secondsLeft <= 1) {
      t.cancel();
      setState(() => _isRunning = false);
      if (_isResting) {
        _nextRound();
      } else {
        _startRest();
      }
    } else {
      setState(() => _secondsLeft--);
    }
  }

  void _startRest() {
    if (_currentRound + 1 >= _ex.rounds) {
      _finish();
      return;
    }
    setState(() {
      _isResting = true;
      _secondsLeft = _ex.rest;
    });
    _progressCtrl.duration = Duration(seconds: _ex.rest);
    _progressCtrl.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    setState(() => _isRunning = true);
  }

  void _nextRound() {
    setState(() {
      _isResting = false;
      _currentRound++;
      _secondsLeft = _ex.duration;
    });
    _progressCtrl.duration = Duration(seconds: _ex.duration);
    _progressCtrl.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    setState(() => _isRunning = true);
  }

  Future<void> _finish() async {
    setState(() { _done = true; _isRunning = false; });
    _timer?.cancel();
    final user = context.read<WazniUserProvider>().user;
    if (user != null) {
      await WazniFirebaseService.instance.addWorkout(
        user.uid,
        WorkoutSession(
          exerciseName: _ex.name,
          rounds: _ex.rounds,
          pointsEarned: 10,
          ts: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Color get _typeColor {
    switch (_ex.type) {
      case 'cardio':  return const Color(0xFFFA8231);
      case 'abs':     return const Color(0xFFFF6B9D);
      case 'lower':   return const Color(0xFFC44DFF);
      case 'upper':   return const Color(0xFF4facfe);
      case 'stretch': return const Color(0xFF43E97B);
      default:        return WazniTheme.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ex.name, style: GoogleFonts.tajawal()),
        backgroundColor: _typeColor,
      ),
      body: _done ? _buildDoneScreen() : _buildTimerScreen(),
    );
  }

  Widget _buildTimerScreen() {
    final progress = _secondsLeft / _totalSeconds;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Round indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_ex.rounds, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 28,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: i < _currentRound
                      ? _typeColor
                      : i == _currentRound
                          ? _typeColor.withValues(alpha: 0.5)
                          : WazniTheme.border,
                ),
              )),
            ),

            const SizedBox(height: 8),
            Text(
              _isResting ? 'استراحة' : 'جولة ${_currentRound + 1} من ${_ex.rounds}',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: _isResting ? WazniTheme.green : _typeColor,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            // Circular timer
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: _CirclePainter(
                          progress: 1 - progress,
                          color: _isResting ? WazniTheme.green : _typeColor,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _ex.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                      Text(
                        '$_secondsLeft',
                        style: GoogleFonts.tajawal(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: _isResting ? WazniTheme.green : _typeColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        'ثانية',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: WazniTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _isResting ? '😮‍💨 خذي نفسكِ...' : _ex.desc,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: WazniTheme.inkMuted,
                fontStyle: _isResting ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                _controlBtn(
                  icon: Icons.refresh_rounded,
                  color: WazniTheme.inkFaint,
                  onTap: () {
                    _timer?.cancel();
                    _progressCtrl.stop();
                    setState(() {
                      _currentRound = 0;
                      _isResting = false;
                      _isRunning = false;
                      _secondsLeft = _ex.duration;
                    });
                  },
                ),
                const SizedBox(width: 20),
                // Play/Pause
                GestureDetector(
                  onTap: _isRunning ? _pause : _start,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _typeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _typeColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Skip
                _controlBtn(
                  icon: Icons.skip_next_rounded,
                  color: WazniTheme.inkFaint,
                  onTap: () {
                    _timer?.cancel();
                    _progressCtrl.stop();
                    setState(() => _isRunning = false);
                    if (_isResting) {
                      _nextRound();
                    } else {
                      _startRest();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: WazniTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: WazniTheme.border),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildDoneScreen() {
    final rand = Random();
    final mot = kMotivations[rand.nextInt(kMotivations.length)];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mot.$1, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              mot.$2,
              style: GoogleFonts.tajawal(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: WazniTheme.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              mot.$3,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: WazniTheme.inkMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Points badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: WazniTheme.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: WazniTheme.orange.withValues(alpha: 0.4)),
              ),
              child: Text(
                '⭐ +10 نقاط',
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: WazniTheme.orange,
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _typeColor,
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () => context.pop(),
              child: Text(
                'العودة للتمارين',
                style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.progress != progress || old.color != color;
}
