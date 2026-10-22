import 'dart:convert';
import 'dart:typed_data';

class Profil {
  final String uid;
  final String nom;
  final String bio;
  final String? photoBase64;

  const Profil({
    required this.uid,
    this.nom = '',
    this.bio = '',
    this.photoBase64,
  });

  factory Profil.fromMap(String uid, Map<String, dynamic>? data) {
    return Profil(
      uid: uid,
      nom: (data?['nom'] as String?) ?? '',
      bio: (data?['bio'] as String?) ?? '',
      photoBase64: data?['photoBase64'] as String?,
    );
  }

  // Photo décodée, prête à être affichée (null s'il n'y a pas de photo)
  Uint8List? get photoOctets {
    final texte = photoBase64;
    if (texte == null || texte.isEmpty) return null;
    return base64Decode(texte);
  }
}