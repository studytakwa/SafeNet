import 'package:cloud_firestore/cloud_firestore.dart';

/// ⚠️ À adapter à votre base : collection des profils et noms des champs
/// (regardez votre profil_service.dart / profil_model.dart).
const kCollectionProfils = 'profils';
const kChampNom = 'nom';
const kChampEmail = 'email';
const kChampBio = 'bio';

class AdminStats {
  final int utilisateurs;
  final int enAttente;
  final int acceptees;
  final int refusees;

  const AdminStats({
    required this.utilisateurs,
    required this.enAttente,
    required this.acceptees,
    required this.refusees,
  });
}

/// Un utilisateur tel que l'administrateur le consulte (lecture seule).
class AdminUser {
  final String uid;
  final String nom;
  final String email;
  final String bio;
  final bool bloque;
  final String? motifBlocage;

  /// Tous les champs du document Firestore (pour la fiche détaillée).
  final Map<String, dynamic> champs;

  const AdminUser({
    required this.uid,
    required this.nom,
    required this.email,
    required this.bio,
    this.bloque = false,
    this.motifBlocage,
    required this.champs,
  });

  factory AdminUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return AdminUser(
      uid: d.id,
      nom: '${m[kChampNom] ?? ''}',
      email: '${m[kChampEmail] ?? ''}',
      bio: '${m[kChampBio] ?? ''}',
      bloque: (m['bloque'] as bool?) ?? (m['blocked'] as bool?) ?? false,
      motifBlocage: m['motifBlocage'] as String?,
      champs: m,
    );
  }
}