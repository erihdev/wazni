import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wazni/models/user_model.dart';
import 'package:wazni/models/entry_model.dart';
import 'package:wazni/models/workout_model.dart';
import 'package:wazni/models/inbody_model.dart';

/// Singleton — نفس نمط ZyiarahFirebaseService
class WazniFirebaseService {
  WazniFirebaseService._();
  static final WazniFirebaseService instance = WazniFirebaseService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // ── Auth ─────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<WazniUser> register({
    required String name,
    required String email,
    required String password,
    double? startWeight,
    double? goalWeight,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    final uid = cred.user!.uid;

    // توليد كود فريد
    String code = _genCode();
    while ((await _db.collection('codes').doc(code).get()).exists) {
      code = _genCode();
    }

    final user = WazniUser(
      uid: uid, name: name, email: email, code: code,
      startWeight: startWeight, goalWeight: goalWeight,
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    await _db.collection('codes').doc(code).set({'uid': uid, 'email': email});

    if (startWeight != null && startWeight > 0) {
      await _db.collection('entries').doc(uid).set({
        'data': [WeightEntry(label: 'البداية', weight: startWeight, ts: DateTime.now().millisecondsSinceEpoch).toMap()]
      });
    }

    return user;
  }

  // ── User ─────────────────────────────────────────────────────
  Future<WazniUser?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists ? WazniUser.fromFirestore(snap) : null;
  }

  // ── Entries ──────────────────────────────────────────────────
  Stream<List<WeightEntry>> entriesStream(String uid) =>
      _db.collection('entries').doc(uid).snapshots().map((snap) {
        if (!snap.exists) return [];
        final raw = List<Map<String, dynamic>>.from(snap.data()?['data'] ?? []);
        return raw.map(WeightEntry.fromMap).toList();
      });

  Future<void> addEntry(String uid, WeightEntry entry) async {
    final snap = await _db.collection('entries').doc(uid).get();
    final data = snap.exists ? List<Map<String,dynamic>>.from(snap.data()?['data'] ?? []) : [];
    data.add(entry.toMap());
    await _db.collection('entries').doc(uid).set({'data': data});
  }

  Future<void> removeEntry(String uid, int index) async {
    final snap = await _db.collection('entries').doc(uid).get();
    final data = List<Map<String,dynamic>>.from(snap.data()?['data'] ?? []);
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await _db.collection('entries').doc(uid).set({'data': data});
    }
  }

  Future<void> clearEntries(String uid) =>
      _db.collection('entries').doc(uid).set({'data': []});

  Future<List<WeightEntry>> getEntries(String uid) async {
    final snap = await _db.collection('entries').doc(uid).get();
    if (!snap.exists) return [];
    return List<Map<String,dynamic>>.from(snap.data()?['data'] ?? [])
        .map(WeightEntry.fromMap).toList();
  }

  // ── Challenge ────────────────────────────────────────────────
  Future<String?> uidFromCode(String code) async {
    final snap = await _db.collection('codes').doc(code).get();
    if (!snap.exists) return null;
    final d = snap.data() as Map<String, dynamic>?;
    return d?['uid'] as String?;
  }

  Future<void> addChallenge(String myUid, String friendUid) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(myUid),
        {'challenges': FieldValue.arrayUnion([friendUid])});
    batch.update(_db.collection('users').doc(friendUid),
        {'challenges': FieldValue.arrayUnion([myUid])});
    await batch.commit();
  }

  Future<void> removeChallenge(String myUid, String friendUid) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(myUid),
        {'challenges': FieldValue.arrayRemove([friendUid])});
    batch.update(_db.collection('users').doc(friendUid),
        {'challenges': FieldValue.arrayRemove([myUid])});
    await batch.commit();
  }

  // ── Workouts ─────────────────────────────────────────────────
  Stream<List<WorkoutSession>> workoutsStream(String uid) =>
      _db.collection('workouts').doc(uid).snapshots().map((snap) {
        if (!snap.exists) return [];
        final raw = List<Map<String, dynamic>>.from(snap.data()?['data'] ?? []);
        return raw.map(WorkoutSession.fromMap).toList();
      });

  Future<void> addWorkout(String uid, WorkoutSession session) async {
    final snap = await _db.collection('workouts').doc(uid).get();
    final data = snap.exists ? List<Map<String,dynamic>>.from(snap.data()?['data'] ?? []) : [];
    data.add(session.toMap());
    await _db.collection('workouts').doc(uid).set({'data': data});
    // Increment user points
    await _db.collection('users').doc(uid).update({
      'totalPoints': FieldValue.increment(session.pointsEarned),
      'totalExercises': FieldValue.increment(1),
    });
  }

  // ── InBody ───────────────────────────────────────────────────
  Stream<List<InBodyRecord>> inBodyStream(String uid) =>
      _db.collection('inbody').doc(uid).snapshots().map((snap) {
        if (!snap.exists) return [];
        final raw = List<Map<String, dynamic>>.from(snap.data()?['data'] ?? []);
        return raw.map(InBodyRecord.fromMap).toList();
      });

  Future<void> addInBody(String uid, InBodyRecord record) async {
    final snap = await _db.collection('inbody').doc(uid).get();
    final data = snap.exists ? List<Map<String,dynamic>>.from(snap.data()?['data'] ?? []) : [];
    data.add(record.toMap());
    await _db.collection('inbody').doc(uid).set({'data': data});
  }

  // ── Prayers ──────────────────────────────────────────────────
  Stream<Map<String, bool>> prayersStream(String uid, String date) =>
      _db.collection('prayers').doc(uid).snapshots().map((snap) {
        if (!snap.exists) return {};
        final dayData = snap.data()?[date] as Map<dynamic, dynamic>?;
        if (dayData == null) return {};
        return dayData.map((k, v) => MapEntry(k.toString(), v == true));
      });

  Stream<List<Map<String, dynamic>>> prayerHistoryStream(String uid) =>
      _db.collection('prayers').doc(uid).snapshots().map((snap) {
        if (!snap.exists) return [];
        final data = snap.data() ?? {};
        final entries = data.entries
            .where((e) => e.key != '_placeholder')
            .map((e) => {
              'date': e.key,
              'prayers': e.value is Map ? e.value : {},
            })
            .toList();
        entries.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        return entries;
      });

  Future<void> togglePrayer({
    required String uid,
    required String date,
    required String prayerKey,
    required bool currentValue,
    required int pointsDelta,
    required bool wasAllFive,
    required bool willBeAllFive,
  }) async {
    final ref = _db.collection('prayers').doc(uid);
    await ref.set({date: {prayerKey: !currentValue}}, SetOptions(merge: true));
    // Update points: base prayer points + bonus for completing all five
    int delta = !currentValue ? pointsDelta : -pointsDelta;
    if (willBeAllFive) delta += 50;   // earned the all-five bonus
    if (wasAllFive && currentValue) delta -= 50; // lost the all-five bonus
    if (delta != 0) {
      await _db.collection('users').doc(uid).update({
        'totalPoints': FieldValue.increment(delta),
      });
    }
  }

  // ── Util ─────────────────────────────────────────────────────
  String _genCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[(DateTime.now().microsecondsSinceEpoch + chars.length * _) % chars.length]).join();
  }
}
