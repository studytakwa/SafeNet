import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import 'social_controller.dart';

class PostController {
  final _db = FirebaseFirestore.instance;
  final _social = SocialController();

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  /// Fil d'actualité (les photos étant dans les documents, on limite à 20).
  Stream<List<PostModel>> flux() => _posts
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((s) => s.docs.map(PostModel.fromDoc).toList());

  /// Publications d'un utilisateur (page profil).
  /// Tri côté client pour éviter de créer un index Firestore.
  Stream<List<PostModel>> fluxUtilisateur(String userId) => _posts
      .where('authorId', isEqualTo: userId)
      .snapshots()
      .map((s) {
    final l = s.docs.map(PostModel.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  });

  /// Publications des amis (Firestore limite `whereIn` à 30 valeurs).
  Stream<List<PostModel>> fluxAmis(List<String> ids) {
    if (ids.isEmpty) return Stream.value(<PostModel>[]);
    return _posts
        .where('authorId', whereIn: ids.take(30).toList())
        .snapshots()
        .map((s) {
      final l = s.docs.map(PostModel.fromDoc).toList();
      l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return l.take(20).toList();
    });
  }

  Future<void> publier({
    required String authorName,
    required String text,
    Uint8List? imageBytes,
  }) {
    return _posts.add({
      'authorId': uid,
      'authorName': authorName,
      'text': text,
      'imageBase64': imageBytes != null ? base64Encode(imageBytes) : null,
      'createdAt': FieldValue.serverTimestamp(),
      'edited': false,
      'likes': <String>[],
      'commentCount': 0,
    });
  }

  Future<void> modifier(String postId, String text) =>
      _posts.doc(postId).update({'text': text, 'edited': true});

  Future<void> supprimer(PostModel post) async {
    final coms = await _posts.doc(post.id).collection('comments').get();
    final batch = _db.batch();
    for (final d in coms.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_posts.doc(post.id));
    await batch.commit();
  }

  Future<void> basculerLike(PostModel post) async {
    final liked = post.likedBy(uid);
    await _posts.doc(post.id).update({
      'likes': liked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
    if (!liked) {
      await _social.notifier(post.authorId, 'like', postId: post.id);
    }
  }

  Stream<List<CommentModel>> commentaires(String postId) => _posts
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(CommentModel.fromDoc).toList());

  Future<void> commenter(String postId, String authorName, String text) async {
    final ref = _posts.doc(postId);
    await ref.collection('comments').add({
      'authorId': uid,
      'authorName': authorName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.update({'commentCount': FieldValue.increment(1)});
    final auteur = (await ref.get()).data()?['authorId'] as String?;
    await _social.notifier(auteur ?? '', 'comment', postId: postId);
  }

  Future<void> supprimerCommentaire(String postId, String commentId) async {
    final ref = _posts.doc(postId);
    await ref.collection('comments').doc(commentId).delete();
    await ref.update({'commentCount': FieldValue.increment(-1)});
  }
}