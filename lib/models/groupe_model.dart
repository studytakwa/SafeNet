import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Thèmes proposés à la création d'un groupe.
const kThemes = [
  'Sciences',
  'Sport',
  'Art',
  'Musique',
  'Jeux',
  'Lecture',
  'Autre',
];

IconData iconeTheme(String theme) {
  switch (theme) {
    case 'Sciences':
      return Icons.science_outlined;
    case 'Sport':
      return Icons.sports_soccer_outlined;
    case 'Art':
      return Icons.palette_outlined;
    case 'Musique':
      return Icons.music_note_outlined;
    case 'Jeux':
      return Icons.sports_esports_outlined;
    case 'Lecture':
      return Icons.menu_book_outlined;
    default:
      return Icons.category_outlined;
  }
}

class GroupModel {
  final String id;
  final String name;
  final String theme;
  final String description;
  final String creatorId;
  final List<String> members;
  final List<String> pendingRequests;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.theme,
    required this.description,
    required this.creatorId,
    required this.members,
    required this.pendingRequests,
    required this.createdAt,
  });

  bool isMember(String uid) => members.contains(uid);
  bool isPending(String uid) => pendingRequests.contains(uid);

  factory GroupModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final membersList = List<String>.from(m['members'] ?? const []);
    final rawCreator = (m['creatorId'] as String?) ?? '';
    final creator = rawCreator.isNotEmpty
        ? rawCreator
        : (membersList.isNotEmpty ? membersList.first : '');
    return GroupModel(
      id: d.id,
      name: (m['name'] as String?) ?? '',
      theme: (m['theme'] as String?) ?? 'Autre',
      description: (m['description'] as String?) ?? '',
      creatorId: creator,
      members: membersList,
      pendingRequests: List<String>.from(m['pendingRequests'] ?? const []),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class GroupMessage {
  final String id;
  final String senderId;
  final String text;
  final String? fileName;
  final String? fileBase64;
  final String? fileType; // 'pdf' | 'document' | 'course' | 'image'
  final DateTime createdAt;

  const GroupMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.fileName,
    this.fileBase64,
    this.fileType,
    required this.createdAt,
  });

  factory GroupMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return GroupMessage(
      id: d.id,
      senderId: (m['senderId'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      fileName: m['fileName'] as String?,
      fileBase64: m['fileBase64'] as String?,
      fileType: m['fileType'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
