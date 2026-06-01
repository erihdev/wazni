import 'package:cloud_firestore/cloud_firestore.dart';

class WazniUser {
  final String uid;
  final String name;
  final String email;
  final String code;
  final double? startWeight;
  final double? goalWeight;
  final List<String> challenges;
  final DateTime? createdAt;
  final int totalPoints;
  final int totalExercises;

  const WazniUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.code,
    this.startWeight,
    this.goalWeight,
    this.challenges = const [],
    this.createdAt,
    this.totalPoints = 0,
    this.totalExercises = 0,
  });

  factory WazniUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WazniUser(
      uid:         doc.id,
      name:        d['name'] ?? '',
      email:       d['email'] ?? '',
      code:        d['code'] ?? '',
      startWeight: (d['startWeight'] as num?)?.toDouble(),
      goalWeight:  (d['goalWeight']  as num?)?.toDouble(),
      challenges:     List<String>.from(d['challenges'] ?? []),
      createdAt:      (d['createdAt'] as Timestamp?)?.toDate(),
      totalPoints:    (d['totalPoints'] as num?)?.toInt() ?? 0,
      totalExercises: (d['totalExercises'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':        name,
    'email':       email,
    'code':        code,
    'startWeight': startWeight,
    'goalWeight':  goalWeight,
    'challenges':  challenges,
    'createdAt':   FieldValue.serverTimestamp(),
  };

  String get initials =>
      name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase().substring(0, name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').join().length.clamp(0, 2));
}
