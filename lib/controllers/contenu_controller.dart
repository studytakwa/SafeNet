import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contenu_model.dart';

class ContenuController {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('contenus');

  /// Tous les contenus, du plus récent au plus ancien.
  /// Le filtrage (type, thème, recherche) se fait dans l'écran,
  /// ce qui évite de créer des index Firestore.
  Stream<List<Contenu>> tous() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Contenu.fromDoc).toList());

  Future<String> _nomAuteur() async {
    try {
      final p = await _db.collection('profils').doc(uid).get();
      final nom = p.data()?['nom'] as String?;
      if (nom != null && nom.isNotEmpty) return nom;
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.displayName ?? 'Utilisateur';
  }

  Future<void> partager({
    required String titre,
    required String description,
    required String type,
    required String categorie,
    String lien = '',
  }) async {
    await _col.add({
      'auteurId': uid,
      'auteurNom': await _nomAuteur(),
      'titre': titre,
      'description': description,
      'type': type,
      'categorie': categorie,
      'lien': lien,
      'utiles': <String>[],
      'date': FieldValue.serverTimestamp(),
    });
  }

  /// Ajoute ou retire mon « Utile ».
  Future<void> basculerUtile(Contenu c) => _col.doc(c.id).update({
    'utiles': c.estUtilePour(uid)
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
  });

  Future<void> supprimer(String id) => _col.doc(id).delete();
}