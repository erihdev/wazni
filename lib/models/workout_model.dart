class WorkoutSession {
  final String exerciseName;
  final int rounds;
  final int pointsEarned;
  final int ts;

  WorkoutSession({
    required this.exerciseName,
    required this.rounds,
    required this.pointsEarned,
    required this.ts,
  });

  Map<String, dynamic> toMap() => {
    'exerciseName': exerciseName,
    'rounds': rounds,
    'pointsEarned': pointsEarned,
    'ts': ts,
  };

  factory WorkoutSession.fromMap(Map<String, dynamic> m) => WorkoutSession(
    exerciseName: m['exerciseName'] ?? '',
    rounds: m['rounds'] ?? 0,
    pointsEarned: m['pointsEarned'] ?? 10,
    ts: m['ts'] ?? 0,
  );
}
