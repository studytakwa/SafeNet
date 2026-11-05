import 'package:flutter/material.dart';
import '../../controllers/social_controller.dart';
import '../../models/social_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../profil/profil_page.dart';
import 'chat_page.dart';
import 'user_builder.dart';

/// Liste des amis et des demandes reçues.
class AmisPage extends StatelessWidget {
  const AmisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SocialController();
    return DefaultTabController(
      length: 2,
      child: StreamBuilder<List<RelationModel>>(
        stream: s.mesRelations(),
        builder: (context, snap) {
          final rels = snap.data ?? [];
          final amis = rels.where((r) => r.isFriends).toList();
          final demandes = rels
              .where((r) => !r.isFriends && r.requester != s.uid)
              .toList();

          return Scaffold(
            backgroundColor: HomeColors.bg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.primaryDark),
              title: const Text(
                'Mes amis',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                labelColor: AppColors.primaryDark,
                unselectedLabelColor: Colors.black45,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: [
                  Tab(text: 'Amis (${amis.length})'),
                  Tab(text: 'Demandes (${demandes.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _Liste(
                  vide: "Vous n'avez pas encore d'amis.\nCherchez une personne et ouvrez son profil pour l'ajouter.",
                  rels: amis,
                  me: s.uid,
                  trailing: (other) => IconButton(
                    tooltip: 'Message',
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatPage(otherUid: other)),
                    ),
                  ),
                ),
                _Liste(
                  vide: 'Aucune demande en attente.',
                  rels: demandes,
                  me: s.uid,
                  trailing: (other) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Accepter',
                        icon: const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary),
                        onPressed: () => s.accepter(other),
                      ),
                      IconButton(
                        tooltip: 'Refuser',
                        icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                        onPressed: () => s.retirer(other),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Liste extends StatelessWidget {
  final String vide;
  final List<RelationModel> rels;
  final String me;
  final Widget Function(String other) trailing;
  const _Liste({
    required this.vide,
    required this.rels,
    required this.me,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (rels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vide,
            textAlign: TextAlign.center,
            style: const TextStyle(color: HomeColors.mute, height: 1.4),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: rels.length,
      itemBuilder: (_, i) {
        final other = rels[i].other(me);
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HomeColors.line),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: UserAvatar(uid: other),
            title: UserName(
              uid: other,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            trailing: trailing(other),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilPage(uid: other)),
            ),
          ),
        );
      },
    );
  }
}
