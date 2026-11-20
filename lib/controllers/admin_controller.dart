import '../models/admin_models.dart';
import '../models/post_model.dart';
import '../services/admin_service.dart';
class AdminController {
  final _service = AdminService();

  String get uid => _service.uid;

  Stream<bool> roleAdmin() => _service.roleAdmin();

  Future<void> deconnecter() => _service.deconnecter();

  // Tableau de bord
  Future<AdminStats> statistiques() => _service.statistiques();

  // Utilisateurs
  Stream<List<AdminUser>> utilisateurs() => _service.utilisateurs();
  List<AdminUser> filtrer(List<AdminUser> liste, String recherche) {
    final q = recherche.trim().toLowerCase();
    if (q.isEmpty) return liste;
    return liste.where((u) => u.nom.toLowerCase().contains(q)).toList();
  }

  Stream<List<PostModel>> publicationsUtilisateur(String userId) =>
      _service.publicationsUtilisateur(userId);

  Future<void> bloquerUtilisateur(String userId, {String? motif}) =>
      _service.bloquerUtilisateur(userId, motif: motif);

  Future<void> debloquerUtilisateur(String userId) =>
      _service.debloquerUtilisateur(userId);

  Future<void> supprimerCompteUtilisateur(String userId) =>
      _service.supprimerCompteUtilisateur(userId);

  // Modération
  Stream<List<PostModel>> publications(String statut) =>
      _service.publications(statut);

  Future<void> accepter(PostModel p) => _service.accepter(p);

  Future<void> refuser(PostModel p, String motif) =>
      _service.refuser(p, motif);
}