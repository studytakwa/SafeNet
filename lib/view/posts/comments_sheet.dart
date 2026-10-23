import 'package:flutter/material.dart';
import '../../../controllers/post_controller.dart';
import '../../../controllers/profil_controller.dart';
import '../../../models/post_model.dart';
import '../../../models/profil_model.dart';
import '/view/Home/widgets/home_common.dart';
import 'post_card.dart' show formatDate;

void showCommentsSheet(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _CommentsSheet(postId: postId),
      ),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _posts = PostController();
  final _tc = TextEditingController();
  late final Stream<ProfilModel>? _profilStream;
  late final Stream<List<CommentModel>> _comments;
  String _nom = '';

  @override
  void initState() {
    super.initState();
    final pc = ProfilController();
    final uid = pc.uidCourant;
    _profilStream = uid.isNotEmpty ? pc.suivreProfil(uid) : null;
    _comments = _posts.commentaires(widget.postId);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _tc.text.trim();
    if (t.isEmpty) return;
    _tc.clear();
    await _posts.commenter(widget.postId, _nom, t);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text('Commentaires',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: HomeColors.ink)),
        const Divider(color: HomeColors.line),
        Expanded(
          child: StreamBuilder<List<CommentModel>>(
            stream: _comments,
            builder: (context, snap) {
              final list = snap.data ?? [];
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return const Center(
                  child: Text('Aucun commentaire. Soyez le premier !',
                      style: TextStyle(color: HomeColors.mute)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final mine = c.authorId == _posts.uid;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Avatar(
                          letter: c.authorName.isEmpty
                              ? '?'
                              : c.authorName[0].toUpperCase(),
                          color: HomeColors.blue,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: HomeColors.input,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.authorName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(c.text),
                                const SizedBox(height: 4),
                                Text(formatDate(c.createdAt),
                                    style: const TextStyle(
                                        color: HomeColors.mute,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        if (mine)
                          IconButton(
                            tooltip: 'Supprimer',
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: HomeColors.mute),
                            onPressed: () => _posts.supprimerCommentaire(
                                widget.postId, c.id),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1, color: HomeColors.line),
        StreamBuilder<ProfilModel>(
          stream: _profilStream,
          builder: (context, snap) {
            _nom = snap.data?.nom ?? _nom;
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tc,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Écrire un commentaire…',
                        filled: true,
                        fillColor: HomeColors.input,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    style: IconButton.styleFrom(
                        backgroundColor: HomeColors.brand),
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}