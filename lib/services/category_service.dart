import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Future<List<String>> chargerCategories() async {
    final Set<String> categories = {
      'Sciences', 'Sport', 'Art', 'Informatique', 'Musique', 'Jeux', 'Lecture',
      'Général', 'Soutien scolaire', 'Orientation', 'Bien-être', 'Projets', 'Autre'
    };

    try {
      final catSnap = await _db.collection('categories').get();
      for (final doc in catSnap.docs) {
        final nom = '${doc.data()['nom'] ?? ''}'.trim();
        if (nom.isNotEmpty) categories.add(nom);
      }

      final futures = await Future.wait([
        _db.collection('quizzes').get(),
        _db.collection('contenus').get(),
        _db.collection('posts').get(),
        _db.collection('groups').get(),
      ]);

      for (final snap in futures) {
        for (final doc in snap.docs) {
          final data = doc.data();
          final cat = '${data['categorie'] ?? data['theme'] ?? ''}'.trim();
          if (cat.isNotEmpty) categories.add(cat);
        }
      }
    } catch (_) {}

    final liste = categories.toList();
    liste.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return liste;
  }

  Future<void> ajouterCategorie(String nouvelleCategorie) async {
    final cat = nouvelleCategorie.trim();
    if (cat.isEmpty) return;
    try {
      await _db.collection('categories').doc(cat.toLowerCase()).set({
        'nom': cat,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
