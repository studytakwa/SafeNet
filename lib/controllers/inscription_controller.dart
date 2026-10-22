import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class InscriptionController {
  final AuthService _authService = AuthService();

  int calculerAge(DateTime naissance) {
    final maintenant = DateTime.now();
    var age = maintenant.year - naissance.year;
    if (maintenant.month < naissance.month ||
        (maintenant.month == naissance.month &&
            maintenant.day < naissance.day)) {
      age--;
    }
    return age;
  }

  Future<String?> inscrire({
    required String email,
    required String motDePasse,
    required DateTime? dateNaissance,
  }) async {
    if (dateNaissance == null) {
      return 'Choisissez votre date de naissance';
    }

    if (calculerAge(dateNaissance) >= 18) {
      return 'Inscription refusée : moins de 18 ans requis';
    }

    try {
      await _authService.inscrireUtilisateur(
        email: email,
        motDePasse: motDePasse,
        dateNaissance: dateNaissance,
      );
      return null; // Succès
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'weak-password':
          return 'Mot de passe trop faible.';
        case 'invalid-email':
          return 'Email invalide.';
        default:
          return 'Création du compte impossible. Réessayez.';
      }
    } catch (e) {
      return 'Erreur, réessayez.';
    }
  }
}
