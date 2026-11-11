import 'package:flutter/material.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
import 'home_common.dart';
import '/view/posts/post_card.dart';

/// Liste de publications.
/// - `PostsList()` : fil d'actualité (accueil)
/// - `PostsList(uid: monUid)` : publications d'un utilisateur (page profil)
/// - `PostsList(authorIds: [...])` : publications de ces utilisateurs (amis)
/// - `type: 'astuce' | 'note' | 'question'` : filtre par type de publication
/// À placer dans un SingleChildScrollView / Column (pas de scroll interne).
class PostsList extends StatefulWidget {
  final String? uid;
  final List<String>? authorIds;
  final String? type;
  const PostsList({super.key, this.uid, this.authorIds, this.type});

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
    if (old.uid != widget.uid ||
        old.type != widget.type ||
        old.authorIds?.join(',') != widget.authorIds?.join(',')) {
      _stream = _build();
    }
  }

  Stream<List<PostModel>> _build() {
    final c = PostController();
    final type = widget.type;

    if (widget.authorIds != null) {
      final s = c.fluxAmis(widget.authorIds!);
      return type == null
          ? s
          : s.map((l) => l.where((p) => p.type == type).toList());
    }
    if (widget.uid != null) {
      final s = c.fluxUtilisateur(widget.uid!);
      return type == null
          ? s
          : s.map((l) => l.where((p) => p.type == type).toList());
    }
    return type == null ? c.flux() : c.fluxParType(type);
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
          children: [
            for (final p in posts) PostCard(key: ValueKey(p.id), post: p)
          ],
        );
      },
    );
  }
}