import '../services/admin_service.dart';

class AdminAuthController {
  final _service = AdminService();
  Future<bool> dejaConnecteAdmin() async {
    final u = _service.utilisateurCourant;
    if (u == null) return false;
    try {
      return await _service.aRoleAdmin(u.uid);
    } catch (_) {
      return false;
    }
  }
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