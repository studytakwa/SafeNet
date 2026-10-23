import 'dart:typed_data';
import '../models/profil_model.dart';
import '../services/profil_service.dart';

class ProfilController {
  final ProfilService _profilService = ProfilService();

  String get uidCourant => _profilService.uidCourant;

  Stream<ProfilModel> suivreProfil(String uid) {
    return _profilService.suivreProfil(uid);
  }

  /// Profils disponibles pour la recherche.
  Future<List<ProfilModel>> chargerProfils() {
    return _profilService.chargerProfils();
  }

  Future<String?> enregistrer({
    required String nom,
    required String bio,
    Uint8List? photo,
  }) async {
    final nomEpure = nom.trim();
    if (nomEpure.isEmpty) {
      return 'Entrez votre nom';
    }
    if (nomEpure.length < 2) {
      return 'Nom trop court (2 caractères minimum)';
    }
    if (nomEpure.length > 30) {
      return '30 caractères maximum';
    }

    try {
      await _profilService.enregistrerProfil(
        uid: uidCourant,
        nom: nomEpure,
        bio: bio.trim(),
        photo: photo,
      );
      return null; // Succès
    } catch (e) {
      return "Impossible d'enregistrer le profil. Réessayez.";
    }
  }
}