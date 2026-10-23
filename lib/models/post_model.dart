import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;

  /// Photo encodée en base64 (stockée directement dans Firestore).
  final String? imageBase64;
  final DateTime createdAt;
  final bool edited;
  final List<String> likes;
  final int commentCount;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.imageBase64,
    required this.createdAt,
    required this.edited,
    required this.likes,
    required this.commentCount,
  });

  bool likedBy(String uid) => likes.contains(uid);

  factory PostModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return PostModel(
      id: d.id,
      authorId: (m['authorId'] as String?) ?? '',
      authorName: (m['authorName'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      imageBase64: m['imageBase64'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edited: (m['edited'] as bool?) ?? false,
      likes: List<String>.from(m['likes'] ?? const []),
      commentCount: (m['commentCount'] as int?) ?? 0,
    );
  }
}

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return CommentModel(
      id: d.id,
      authorId: (m['authorId'] as String?) ?? '',
      authorName: (m['authorName'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}