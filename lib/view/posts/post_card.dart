import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
import 'comments_sheet.dart';
import 'package:safenet/view/Home/widgets/home_common.dart';

String formatDate(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return "À l'instant";
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Une publication : auteur, menu ⋮ (modifier / supprimer), photo,
/// likes et commentaires.
class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ctrl = PostController();
    final isMine = post.authorId == ctrl.uid;
    final liked = post.likedBy(ctrl.uid);
    final lettre =
    post.authorName.isEmpty ? '?' : post.authorName[0].toUpperCase();

    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
            child: Row(
              children: [
                Avatar(letter: lettre, color: HomeColors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName.isEmpty ? 'Utilisateur' : post.authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: HomeColors.ink),
                      ),
                      Text(
                        '${formatDate(post.createdAt)}${post.edited ? ' · modifié' : ''}',
                        style: const TextStyle(
                            color: HomeColors.mute, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isMine)
                  PopupMenuButton<String>(
                    tooltip: 'Options',
                    icon: const Icon(Icons.more_vert, color: HomeColors.mute),
                    onSelected: (v) {
                      if (v == 'edit') _edit(context, ctrl);
                      if (v == 'delete') _delete(context, ctrl);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
              ],
            ),
          ),
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(post.text,
                  style: const TextStyle(fontSize: 15, color: HomeColors.ink)),
            ),
          if (post.imageBase64 != null) ...[
            const SizedBox(height: 12),
            _Base64Image(data: post.imageBase64!),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: HomeColors.brand),
                const SizedBox(width: 4),
                Text('${post.likes.length}',
                    style: const TextStyle(color: HomeColors.mute)),
                const Spacer(),
                Text(
                  '${post.commentCount} commentaire${post.commentCount > 1 ? 's' : ''}',
                  style: const TextStyle(color: HomeColors.mute),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: HomeColors.line),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => ctrl.basculerLike(post),
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.redAccent : HomeColors.mute,
                    size: 20,
                  ),
                  label: Text("J'aime",
                      style: TextStyle(
                          color: liked ? Colors.redAccent : HomeColors.mute,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => showCommentsSheet(context, post.id),
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: HomeColors.mute, size: 20),
                  label: const Text('Commenter',
                      style: TextStyle(
                          color: HomeColors.mute,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, PostController ctrl) async {
    final tc = TextEditingController(text: post.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier la publication'),
        content: TextField(
          controller: tc,
          autofocus: true,
          minLines: 2,
          maxLines: 6,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok == true && tc.text.trim() != post.text) {
      await ctrl.modifier(post.id, tc.text.trim());
    }
  }

  Future<void> _delete(BuildContext context, PostController ctrl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la publication ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) await ctrl.supprimer(post);
  }
}

/// Décode la photo base64 une seule fois (et non à chaque rebuild).
class _Base64Image extends StatefulWidget {
  final String data;
  const _Base64Image({required this.data});

  @override
  State<_Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<_Base64Image> {
  late Uint8List _bytes = base64Decode(widget.data);

  @override
  void didUpdateWidget(covariant _Base64Image old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _bytes = base64Decode(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      _bytes,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (c, e, s) => const SizedBox(
        height: 120,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}