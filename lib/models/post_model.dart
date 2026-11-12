import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

DateTime _parseDate(dynamic t) {
  if (t is Timestamp) return t.toDate();
  if (t is DateTime) return t;
  if (t is String) return DateTime.tryParse(t) ?? DateTime.now();
  return DateTime.now();
}

/// Types de publication : publication simple, astuce, note de cours, question.
const kTypesPost = ['publication', 'astuce', 'note', 'question'];

String libelleTypePost(String t) {
  switch (t) {
    case 'astuce':
      return 'Astuce';
    case 'note':
      return 'Note de cours';
    case 'question':
      return 'Question';
    default:
      return 'Publication';
  }
}

IconData iconeTypePost(String t) {
  switch (t) {
    case 'astuce':
      return Icons.lightbulb_outline_rounded;
    case 'note':
      return Icons.menu_book_outlined;
    case 'question':
      return Icons.help_outline_rounded;
    default:
      return Icons.chat_bubble_outline_rounded;
  }
}

/// Modèle représentant une publication.
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;

  /// 'publication' | 'astuce' | 'note' | 'question'
  final String type;

  /// Thème (Sciences, Sport, Art...). Vide pour une publication simple.
  final String categorie;

  /// Photo encodée en base64 (optionnelle).
  final String? imageBase64;
  final DateTime createdAt;
  final bool edited;
  final List<String> likes;
  final int commentCount;

  /// Modération : 'approved' | 'pending' | 'rejected'
  final String status;
  final String? rejectionReason;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    this.type = 'publication',
    this.categorie = '',
    this.imageBase64,
    required this.createdAt,
    this.edited = false,
    this.likes = const [],
    this.commentCount = 0,
    this.status = 'approved',
    this.rejectionReason,
  });

  bool likedBy(String uid) => uid.isNotEmpty && likes.contains(uid);

  factory PostModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final rawLikes = m['likes'];
    final likesList = rawLikes is List
        ? rawLikes.map((e) => e.toString()).toList()
        : <String>[];

    final rawCount = m['commentCount'];
    final count = rawCount is num ? rawCount.toInt() : 0;

    return PostModel(
      id: d.id,
      authorId: (m['authorId'] as String?) ?? '',
      authorName: (m['authorName'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      type: (m['type'] as String?) ?? 'publication',
      categorie: (m['categorie'] as String?) ?? '',
      imageBase64: m['imageBase64'] as String?,
      createdAt: _parseDate(m['createdAt']),
      edited: (m['edited'] as bool?) ?? false,
      likes: likesList,
      commentCount: count,
      status: (m['status'] as String?) ?? 'approved',
      rejectionReason: m['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'type': type,
      'categorie': categorie,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'createdAt': Timestamp.fromDate(createdAt),
      'edited': edited,
      'likes': likes,
      'commentCount': commentCount,
      'status': status,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}

/// Modèle représentant un commentaire (ou une réponse à une question).
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
      createdAt: _parseDate(m['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}