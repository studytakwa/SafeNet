import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ConnexionController {
  final AuthService _authService = AuthService();

  Future<String?> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      await _authService.seConnecter(
        email: email,
        motDePasse: motDePasse,
      );
      return null; // Succès
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'network-request-failed':
          return 'Pas de connexion internet.';
        default:
          return 'Erreur de connexion. Réessayez.';
      }
    } catch (e) {
      return 'Erreur de connexion. Réessayez.';
    }
  }
}
