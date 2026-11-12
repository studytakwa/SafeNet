import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../models/post_model.dart';
import '../Home/widgets/home_common.dart';
import 'admin_widgets.dart';

/// Gestion des publications : En attente / Acceptées / Refusées.
class AdminPostsPage extends StatefulWidget {
  final int initialTab;
  const AdminPostsPage({super.key, this.initialTab = 0});

  @override
  State<AdminPostsPage> createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends State<AdminPostsPage> {
  final _c = AdminController();
  static const _statuts = ['pending', 'approved', 'rejected'];

  late final List<Stream<List<PostModel>>> _streams = [
    for (final s in _statuts) _c.publications(s),
  ];

  void _message(String texte) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _accepter(PostModel p) async {
    try {
      await _c.accepter(p);
      _message('Publication acceptée : elle est maintenant visible.');
    } catch (e) {
      _message('Action impossible : $e');
    }
  }

  Future<void> _refuser(PostModel p) async {
    final motif = await showDialog<String>(
      context: context,
      builder: (_) => const _MotifDialog(),
    );
    if (motif == null) return; // annulé
    try {
      await _c.refuser(p, motif);
      _message('Publication refusée. L\'auteur a été informé.');
    } catch (e) {
      _message('Action impossible : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: HomeColors.brand,
              indicatorColor: HomeColors.brand,
              tabs: [
                Tab(text: 'En attente'),
                Tab(text: 'Acceptées'),
                Tab(text: 'Refusées'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (var i = 0; i < 3; i++) _liste(_statuts[i], _streams[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liste(String statut, Stream<List<PostModel>> stream) {
    return StreamBuilder<List<PostModel>>(
      stream: stream,
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
        final posts = snap.data!;
        if (posts.isEmpty) {
          return Center(
            child: Text(
              statut == 'pending'
                  ? 'Aucune publication en attente. 🎉'
                  : statut == 'approved'
                  ? 'Aucune publication acceptée.'
                  : 'Aucune publication refusée.',
              style: const TextStyle(color: HomeColors.mute),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final p = posts[i];
            return AdminPostCard(
              key: ValueKey(p.id),
              post: p,
              actions: [
                if (statut != 'approved')
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: couleurStatut('approved')),
                      onPressed: () => _accepter(p),
                      icon: const Icon(Icons.check),
                      label: const Text('Accepter'),
                    ),
                  ),
                if (statut == 'pending') const SizedBox(width: 8),
                if (statut != 'rejected')
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: couleurStatut('rejected')),
                      onPressed: () => _refuser(p),
                      icon: const Icon(Icons.close),
                      label: const Text('Refuser'),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Fenêtre de saisie du motif de refus (facultatif).
class _MotifDialog extends StatefulWidget {
  const _MotifDialog();

  @override
  State<_MotifDialog> createState() => _MotifDialogState();
}

class _MotifDialogState extends State<_MotifDialog> {
  final _tc = TextEditingController();

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Refuser la publication'),
      content: TextField(
        controller: _tc,
        maxLines: 3,
        maxLength: 200,
        decoration: const InputDecoration(
          labelText: 'Motif du refus (facultatif)',
          hintText: 'Ex. : contenu inapproprié',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: couleurStatut('rejected')),
          onPressed: () => Navigator.pop(context, _tc.text),
          child: const Text('Refuser'),
        ),
      ],
    );
  }
}