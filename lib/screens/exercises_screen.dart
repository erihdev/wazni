import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wazni/data/exercises_data.dart';
import 'package:wazni/theme/app_theme.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedCategory = 'all';

  List<Exercise> get _filtered => _selectedCategory == 'all'
      ? kExercises
      : kExercises.where((e) => e.type == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Category chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('all', 'الكل', '⚡', WazniTheme.brand),
                  ...kExerciseCategories.map((c) => _chip(
                    c['key'] as String,
                    c['label'] as String,
                    c['icon'] as String,
                    Color(c['color'] as int),
                  )),
                ],
              ),
            ),
          ),
        ),

        // Exercise cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final ex = _filtered[i];
                return _ExerciseCard(
                  exercise: ex,
                  index: kExercises.indexOf(ex),
                );
              },
              childCount: _filtered.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String key, String label, String icon, Color color) {
    final selected = _selectedCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : WazniTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : WazniTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : WazniTheme.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseCard({required this.exercise, required this.index});

  Color get _typeColor {
    switch (exercise.type) {
      case 'cardio':  return const Color(0xFFFA8231);
      case 'abs':     return const Color(0xFFFF6B9D);
      case 'lower':   return const Color(0xFFC44DFF);
      case 'upper':   return const Color(0xFF4facfe);
      case 'stretch': return const Color(0xFF43E97B);
      default:        return WazniTheme.brand;
    }
  }

  String get _typeLabel {
    switch (exercise.type) {
      case 'cardio':  return 'كارديو';
      case 'abs':     return 'بطن';
      case 'lower':   return 'أرجل';
      case 'upper':   return 'أكتاف';
      case 'stretch': return 'تمدد';
      default:        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/workout', extra: index),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(exercise.icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: WazniTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.desc,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: WazniTheme.inkMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _tag('${exercise.duration}ث × ${exercise.rounds}', _typeColor),
                        const SizedBox(width: 6),
                        _tag(_typeLabel, _typeColor),
                        const SizedBox(width: 6),
                        _tag('+10 ⭐', WazniTheme.orange),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.play_circle_rounded, color: _typeColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}
