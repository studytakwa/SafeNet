import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profil.dart';

class ProfilService {
  static const _collection = 'profils';

  final _db = FirebaseFirestore.instance;

  String get uidCourant => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection(_collection).doc(uid);

  // Suit le profil en temps réel
  Stream<Profil> suivreProfil(String uid) =>
      _doc(uid).snapshots().map((s) => Profil.fromMap(uid, s.data()));

  // Met à jour nom, bio et (si elle a changé) la photo
  Future<void> enregistrer({
    required String nom,
    required String bio,
    Uint8List? photo,
  }) {
    final donnees = <String, dynamic>{
      'nom': nom,
      'bio': bio,
      'misAJourLe': FieldValue.serverTimestamp(),
    };
    if (photo != null) donnees['photoBase64'] = base64Encode(photo);
    return _doc(uidCourant).set(donnees, SetOptions(merge: true));
  }
}