import 'package:flutter/material.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
import 'home_common.dart';
import '/view/posts/post_card.dart';

/// Liste de publications.
/// - `PostsList()` : fil d'actualité (accueil)
/// - `PostsList(uid: monUid)` : publications d'un utilisateur (page profil)
/// À placer dans un SingleChildScrollView / Column (pas de scroll interne).
class PostsList extends StatefulWidget {
  final String? uid;
  const PostsList({super.key, this.uid});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  late Stream<List<PostModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _build();
  }

  @override
  void didUpdateWidget(covariant PostsList old) {
    super.didUpdateWidget(old);
    if (old.uid != widget.uid) _stream = _build();
  }

  Stream<List<PostModel>> _build() {
    final c = PostController();
    return widget.uid == null ? c.flux() : c.fluxUtilisateur(widget.uid!);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erreur : ${snap.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final posts = snap.data ?? [];
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Aucune publication pour le moment.',
                  style: TextStyle(color: HomeColors.mute)),
            ),
          );
        }
        return Column(
          children: [for (final p in posts) PostCard(key: ValueKey(p.id), post: p)],
        );
      },
    );
  }
}