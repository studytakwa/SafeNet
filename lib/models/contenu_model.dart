import 'package:cloud_firestore/cloud_firestore.dart';

const kTypesContenu = ['Note de cours', 'Astuce', 'Ressource'];

class Contenu {
  final String id;
  final String auteurId;
  final String auteurNom;
  final String titre;
  final String description;
  final String type;
  final String categorie;
  final String lien;
  final List<String> utiles;
  final DateTime date;

  const Contenu({
    required this.id,
    required this.auteurId,
    required this.auteurNom,
    required this.titre,
    required this.description,
    required this.type,
    required this.categorie,
    required this.lien,
    required this.utiles,
    required this.date,
  });

  bool estUtilePour(String uid) => utiles.contains(uid);

  factory Contenu.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Contenu(
      id: d.id,
      auteurId: (m['auteurId'] as String?) ?? '',
      auteurNom: (m['auteurNom'] as String?) ?? 'Utilisateur',
      titre: (m['titre'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      type: (m['type'] as String?) ?? 'Astuce',
      categorie: (m['categorie'] as String?) ?? 'Autre',
      lien: (m['lien'] as String?) ?? '',
      utiles: List<String>.from(m['utiles'] ?? const []),
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}