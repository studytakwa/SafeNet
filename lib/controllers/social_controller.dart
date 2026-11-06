import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/social_model.dart';
class SocialController {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Identifiant identique pour A→B et B→A.
  String pairId(String a, String b) =>
      a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

  // ───────────── Amis ─────────────

  Stream<Relation> relation(String other) => _db
      .collection('relations')
      .doc(pairId(uid, other))
      .snapshots()
      .map((s) {
    if (!s.exists) return Relation.none;
    final m = s.data()!;
    if (m['status'] == 'friends') return Relation.friends;
    return m['requester'] == uid ? Relation.sent : Relation.received;
  });

  Stream<List<RelationModel>> mesRelations() => _db
      .collection('relations')
      .where('members', arrayContains: uid)
      .snapshots()
      .map((s) => s.docs.map(RelationModel.fromDoc).toList());

  Stream<List<String>> idsAmis() => mesRelations().map((l) =>
      l.where((r) => r.isFriends).map((r) => r.other(uid)).toList());

  Future<void> envoyerDemande(String other) async {
    await _db.collection('relations').doc(pairId(uid, other)).set({
      'members': [uid, other],
      'status': 'pending',
      'requester': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await notifier(other, 'friend_request');
  }

  Future<void> accepter(String other) async {
    await _db
        .collection('relations')
        .doc(pairId(uid, other))
        .update({'status': 'friends'});
    await notifier(other, 'friend_accepted');
  }

  /// Refuser, annuler une demande ou supprimer un ami.
  Future<void> retirer(String other) =>
      _db.collection('relations').doc(pairId(uid, other)).delete();

  // ───────────── Notifications ─────────────

  Future<void> notifier(String to, String type, {String? postId}) async {
    if (to.isEmpty || to == uid) return;
    await _db.collection('notifications').add({
      'toUid': to,
      'fromUid': uid,
      'type': type,
      'postId': postId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<NotifModel>> notifications() => _db
      .collection('notifications')
      .where('toUid', isEqualTo: uid)
      .snapshots()
      .map((s) {
    final l = s.docs.map(NotifModel.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l.take(50).toList();
  });

  Stream<int> nonLues() =>
      notifications().map((l) => l.where((n) => !n.read).length);

  Future<void> marquerLues() async {
    final snap = await _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  // ───────────── Chat ─────────────

  Stream<List<MessageModel>> messages(String other) => _db
      .collection('chats')
      .doc(pairId(uid, other))
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(MessageModel.fromDoc).toList());

  Future<void> envoyer(String other, String text) async {
    final ref = _db.collection('chats').doc(pairId(uid, other));
    await ref.set({
      'members': [uid, other],
      'lastMessage': text,
      'lastSender': uid,
      'lastAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await ref.collection('messages').add({
      'senderId': uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatModel>> mesConversations() => _db
      .collection('chats')
      .where('members', arrayContains: uid)
      .snapshots()
      .map((s) {
    final l = s.docs.map(ChatModel.fromDoc).toList();
    l.sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return l;
  });
}