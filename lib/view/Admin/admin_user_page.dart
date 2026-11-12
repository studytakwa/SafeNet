import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../models/admin_models.dart';
import '../Home/widgets/home_common.dart';
import '../social/user_builder.dart';
import 'admin_user_detaille_page.dart';

/// Liste de tous les utilisateurs avec recherche par nom (lecture seule).
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _c = AdminController();
  late final Stream<List<AdminUser>> _stream = _c.utilisateurs();
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur par nom…',
              prefixIcon: const Icon(Icons.search, color: HomeColors.mute),
              suffixIcon: _q.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _search.clear();
                  setState(() => _q = '');
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: HomeColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: HomeColors.line),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<AdminUser>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erreur : ${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ),
                );
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final liste = _c.filtrer(snap.data!, _q);
              if (liste.isEmpty) {
                return const Center(
                  child: Text('Aucun utilisateur trouvé.',
                      style: TextStyle(color: HomeColors.mute)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: liste.length,
                itemBuilder: (_, i) {
                  final u = liste[i];
                  return HomeCard(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: UserAvatar(uid: u.uid),
                      title: Text(u.nom.isEmpty ? 'Sans nom' : u.nom,
                          style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (u.email.isNotEmpty)
                            Text(u.email,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (u.bio.isNotEmpty)
                            Text(u.bio,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: HomeColors.mute, fontSize: 12)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AdminUserDetailPage(user: u)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}