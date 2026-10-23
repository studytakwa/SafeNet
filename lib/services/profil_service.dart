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

  /// Charge les profils qui ont un nom (utilisé par la recherche).
  /// Le filtrage par nom se fait ensuite dans l'application.
  Future<List<ProfilModel>> chargerProfils({int limite = 300}) async {
    final snap = await _db.collection(_collection).limit(limite).get();
    return snap.docs
        .map((d) => ProfilModel.fromMap(d.id, d.data()))
        .where((p) => p.nom.isNotEmpty)
        .toList();
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