import '../services/admin_service.dart';

/// Logique de connexion de l'administrateur.
class AdminAuthController {
  final _service = AdminService();

  /// Si un administrateur est déjà connecté, on peut l'envoyer directement
  /// vers son espace.
  Future<bool> dejaConnecteAdmin() async {
    final u = _service.utilisateurCourant;
    if (u == null) return false;
    try {
      return await _service.aRoleAdmin(u.uid);
    } catch (_) {
      return false;
    }
  }

  /// Retourne `null` si la connexion réussit, sinon un message d'erreur.
  /// 1) Firebase Authentication vérifie l'e-mail et le mot de passe.
  /// 2) Firestore vérifie le rôle (`admins/{uid}`).
  /// Un compte non administrateur est immédiatement déconnecté.
  Future<String?> seConnecter(String email, String motDePasse) async {
    try {
      await _service.connecter(email.trim(), motDePasse);
      final currentUid = _service.uid;
      final ok = await _service.aRoleAdmin(currentUid);
      if (!ok) {
        await _service.deconnecter();
        return "Ce compte n'a pas les droits administrateur (vérifiez le document 'admins/$currentUid' dans Firestore).";
      }
      return null;
    } catch (e) {
      if (_service.utilisateurCourant != null) {
        try {
          await _service.deconnecter();
        } catch (_) {}
      }
      return _service.messageAuth(e);
    }
  }
}