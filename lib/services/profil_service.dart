import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profil_model.dart';

class ProfilService {
  static const _collection = 'profils';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uidCourant => FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection(_collection).doc(uid);

  /// Suit le profil en temps réel dans Firestore
  Stream<ProfilModel> suivreProfil(String uid) {
    return _doc(uid).snapshots().map((s) => ProfilModel.fromMap(uid, s.data()));
  }

  /// Met à jour le nom, la bio et la photo dans Firestore
  Future<void> enregistrerProfil({
    required String uid,
    required String nom,
    required String bio,
    Uint8List? photo,
  }) async {
    final donnees = <String, dynamic>{
      'nom': nom,
      'bio': bio,
      'misAJourLe': FieldValue.serverTimestamp(),
    };
    if (photo != null) {
      donnees['photoBase64'] = base64Encode(photo);
    }
    await _doc(uid).set(donnees, SetOptions(merge: true));
  }
}
