import 'dart:convert';
import 'dart:typed_data';

class ProfilModel {
  final String uid;
  final String nom;
  final String bio;
  final String? photoBase64;
  final bool bloque;
  final String? motifBlocage;

  const ProfilModel({
    required this.uid,
    this.nom = '',
    this.bio = '',
    this.photoBase64,
    this.bloque = false,
    this.motifBlocage,
  });

  factory ProfilModel.fromMap(String uid, Map<String, dynamic>? data) {
    return ProfilModel(
      uid: uid,
      nom: (data?['nom'] as String?) ?? '',
      bio: (data?['bio'] as String?) ?? '',
      photoBase64: data?['photoBase64'] as String?,
      bloque: (data?['bloque'] as bool?) ?? (data?['blocked'] as bool?) ?? false,
      motifBlocage: data?['motifBlocage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'bio': bio,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      'bloque': bloque,
      if (motifBlocage != null) 'motifBlocage': motifBlocage,
    };
  }

  Uint8List? get photoOctets {
    final texte = photoBase64;
    if (texte == null || texte.isEmpty) return null;
    return base64Decode(texte);
  }
}

typedef Profil = ProfilModel;
