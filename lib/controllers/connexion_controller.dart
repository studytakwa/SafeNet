import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ConnexionController {
  final AuthService _authService = AuthService();

  Future<String?> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final cred = await _authService.seConnecter(
        email: email,
        motDePasse: motDePasse,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        final bloque = await _authService.isUserBlocked(uid);
        if (bloque) {
          await _authService.seDeconnecter();
          return 'Ce compte a été bloqué par l\'administrateur.';
        }
      }
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
