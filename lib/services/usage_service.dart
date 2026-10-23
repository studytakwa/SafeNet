import 'package:cloud_firestore/cloud_firestore.dart';

class UsageService {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _todayDoc(String uid) {
    final n = DateTime.now();
    final key =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    return _db.collection('users').doc(uid).collection('usage').doc(key);
  }

  Future<int> getTodaySeconds(String uid) async {
    final snap = await _todayDoc(uid).get();
    return (snap.data()?['seconds'] ?? 0) as int;
  }

  Future<void> addSeconds(String uid, int seconds) {
    return _todayDoc(uid).set(
      {'seconds': FieldValue.increment(seconds)},
      SetOptions(merge: true),
    );
  }
}