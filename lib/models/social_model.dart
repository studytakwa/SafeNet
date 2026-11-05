import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _d(dynamic t) => t is Timestamp ? t.toDate() : DateTime.now();

enum Relation { none, sent, received, friends }

/// Lien entre deux utilisateurs : demande en attente ou amitié.
class RelationModel {
  final String id;
  final List<String> members;
  final String status; // 'pending' | 'friends'
  final String requester;

  const RelationModel({
    required this.id,
    required this.members,
    required this.status,
    required this.requester,
  });

  bool get isFriends => status == 'friends';
  String other(String me) =>
      members.firstWhere((m) => m != me, orElse: () => '');

  factory RelationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return RelationModel(
      id: d.id,
      members: List<String>.from(m['members'] ?? const []),
      status: (m['status'] as String?) ?? 'pending',
      requester: (m['requester'] as String?) ?? '',
    );
  }
}

class NotifModel {
  final String id;
  final String fromUid;
  final String type; // friend_request | friend_accepted | like | comment
  final String? postId;
  final bool read;
  final DateTime createdAt;

  const NotifModel({
    required this.id,
    required this.fromUid,
    required this.type,
    required this.postId,
    required this.read,
    required this.createdAt,
  });

  factory NotifModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return NotifModel(
      id: d.id,
      fromUid: (m['fromUid'] as String?) ?? '',
      type: (m['type'] as String?) ?? '',
      postId: m['postId'] as String?,
      read: (m['read'] as bool?) ?? false,
      createdAt: _d(m['createdAt']),
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return MessageModel(
      id: d.id,
      senderId: (m['senderId'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      createdAt: _d(m['createdAt']),
    );
  }
}

class ChatModel {
  final String id;
  final List<String> members;
  final String lastMessage;
  final String lastSender;
  final DateTime lastAt;

  const ChatModel({
    required this.id,
    required this.members,
    required this.lastMessage,
    required this.lastSender,
    required this.lastAt,
  });

  String other(String me) =>
      members.firstWhere((m) => m != me, orElse: () => '');

  factory ChatModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return ChatModel(
      id: d.id,
      members: List<String>.from(m['members'] ?? const []),
      lastMessage: (m['lastMessage'] as String?) ?? '',
      lastSender: (m['lastSender'] as String?) ?? '',
      lastAt: _d(m['lastAt']),
    );
  }
}