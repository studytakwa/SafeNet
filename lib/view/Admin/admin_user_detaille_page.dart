import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../models/admin_models.dart';
import '../../models/post_model.dart';
import '../Home/widgets/home_common.dart';
import '../social/user_builder.dart';
import 'admin_widgets.dart';

/// Fiche complète d'un utilisateur, avec blocage / déblocage.
class AdminUserDetailPage extends StatefulWidget {
  final AdminUser user;
  const AdminUserDetailPage({super.key, required this.user});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  final _c = AdminController();
  late final Stream<List<PostModel>> _posts =
  _c.publicationsUtilisateur(widget.user.uid);

  bool _enCours = false;



  Future<void> _supprimerCompte() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquer et supprimer ce compte ?'),
        content: const Text(
          'Cette action est irréversible. Le compte sera bloqué et définitivement supprimé de Firebase Auth et de la base de données.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Bloquer & Supprimer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _enCours = true);
    try {
      await _c.supprimerCompteUtilisateur(widget.user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte bloqué et supprimé de Firebase avec succès.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(title: Text(u.nom.isEmpty ? 'Utilisateur' : u.nom)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HomeCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    UserAvatar(uid: u.uid, radius: 44),
                    const SizedBox(height: 12),
                    Text(u.nom.isEmpty ? 'Nom non renseigné' : u.nom,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: HomeColors.ink)),
                    const SizedBox(height: 14),
                    _Ligne(Icons.mail_outline, 'E-mail',
                        u.email.isEmpty ? '—' : u.email),
                    _Ligne(Icons.info_outline, 'Bio',
                        u.bio.isEmpty ? 'Aucune bio' : u.bio),
                    _Ligne(Icons.fingerprint, 'Identifiant', u.uid),
                  ],
                ),
              ),

              // ---- Bouton unique : Bloquer (Supprimer de Firebase) ----
              HomeCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bloquer le compte',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red)),
                          Text('Bloquer et supprimer définitivement de Firebase',
                              style: TextStyle(
                                  color: HomeColors.mute, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _enCours ? null : _supprimerCompte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _enCours
                          ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Text('Bloquer'),
                    ),
                  ],
                ),
              ),


              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 12),
                child: Text('Publications',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HomeColors.ink)),
              ),
              StreamBuilder<List<PostModel>>(
                stream: _posts,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Text('Erreur : ${snap.error}',
                        style: const TextStyle(color: Colors.red));
                  }
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final posts = snap.data!;
                  if (posts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Aucune publication.',
                            style: TextStyle(color: HomeColors.mute)),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final p in posts)
                        AdminPostCard(key: ValueKey(p.id), post: p),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valeur;
  const _Ligne(this.icon, this.label, this.valeur);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: HomeColors.brand),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: HomeColors.mute, fontSize: 13)),
          ),
          Expanded(child: Text(valeur, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}