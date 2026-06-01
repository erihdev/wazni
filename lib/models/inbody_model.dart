class InBodyRecord {
  final double weight;
  final double fatPct;
  final double fatKg;
  final double muscleMass;
  final double waterPct;
  final double visceralFat;
  final double bmi;
  final double boneMass;
  final int score;
  final int ts;

  InBodyRecord({
    required this.weight,
    required this.fatPct,
    required this.fatKg,
    required this.muscleMass,
    required this.waterPct,
    required this.visceralFat,
    required this.bmi,
    required this.boneMass,
    required this.score,
    required this.ts,
  });

  Map<String, dynamic> toMap() => {
    'weight': weight, 'fatPct': fatPct, 'fatKg': fatKg,
    'muscleMass': muscleMass, 'waterPct': waterPct,
    'visceralFat': visceralFat, 'bmi': bmi, 'boneMass': boneMass,
    'score': score, 'ts': ts,
  };

  factory InBodyRecord.fromMap(Map<String, dynamic> m) => InBodyRecord(
    weight: (m['weight'] ?? 0).toDouble(),
    fatPct: (m['fatPct'] ?? 0).toDouble(),
    fatKg: (m['fatKg'] ?? 0).toDouble(),
    muscleMass: (m['muscleMass'] ?? 0).toDouble(),
    waterPct: (m['waterPct'] ?? 0).toDouble(),
    visceralFat: (m['visceralFat'] ?? 0).toDouble(),
    bmi: (m['bmi'] ?? 0).toDouble(),
    boneMass: (m['boneMass'] ?? 0).toDouble(),
    score: (m['score'] ?? 0).toInt(),
    ts: (m['ts'] ?? 0).toInt(),
  );
}
