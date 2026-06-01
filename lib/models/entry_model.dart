class WeightEntry {
  final String label;
  final double weight;
  final int ts;

  const WeightEntry({
    required this.label,
    required this.weight,
    required this.ts,
  });

  factory WeightEntry.fromMap(Map<String, dynamic> m) => WeightEntry(
    label:  m['label'] ?? '',
    weight: (m['weight'] as num).toDouble(),
    ts:     m['ts'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'label':  label,
    'weight': weight,
    'ts':     ts,
  };
}
