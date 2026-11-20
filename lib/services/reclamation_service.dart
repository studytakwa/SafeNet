import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReclamationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> envoyerReclamation({
    required String cibleId,
    required String cibleType, // 'post' ou 'profil'
    required String motif,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('reclamations').add({
      'auteurUid': uid,
      'cibleId': cibleId,
      'cibleType': cibleType,
      'motif': motif,
      'createdAt': FieldValue.serverTimestamp(),
      'statut': 'pending',
    });
  }
}
