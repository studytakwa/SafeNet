import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  /// Retourne null si la connexion réussit, sinon le message d'erreur.
  Future<String?> seConnecter(String email, String motDePasse) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );
      return null;
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
    }
  }
}