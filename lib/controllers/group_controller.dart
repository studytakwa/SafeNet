import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/groupe_model.dart';

class DemandeResult {
  final bool success;
  final String message;
  const DemandeResult(this.success, this.message);
}

/// Groupes thématiques (Firestore uniquement).
class GroupController {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  /// Tous les groupes, du plus récent au plus ancien.
  Stream<List<GroupModel>> tousLesGroupes() => _groups.snapshots().map((s) {
    final l = s.docs.map(GroupModel.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  });

  Stream<GroupModel?> groupe(String id) => _groups
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? GroupModel.fromDoc(s) : null);

  Future<String> creer({
    required String name,
    required String theme,
    required String description,
  }) async {
    final ref = await _groups.add({
      'name': name,
      'theme': theme,
      'description': description,
      'creatorId': uid,
      'members': [uid],
      'pendingRequests': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Demander à rejoindre un groupe (envoie une demande au créateur/admin)
  Future<DemandeResult> demanderRejoindre(GroupModel group) async {
    final currentUid = uid;
    if (currentUid.isEmpty) {
      return const DemandeResult(
          false, "Vous devez être connecté pour envoyer une demande.");
    }
    if (group.isMember(currentUid)) {
      return const DemandeResult(
          false, "Vous êtes déjà membre de ce groupe.");
    }
    if (group.isPending(currentUid)) {
      return const DemandeResult(
          true, "Votre demande est déjà en attente de validation.");
    }

    bool updateSuccess = false;
    try {
      await _groups.doc(group.id).update({
        'pendingRequests': FieldValue.arrayUnion([currentUid]),
      });
      updateSuccess = true;
    } catch (_) {
      try {
        await _groups.doc(group.id).set({
          'pendingRequests': FieldValue.arrayUnion([currentUid]),
        }, SetOptions(merge: true));
        updateSuccess = true;
      } catch (e2) {
        return DemandeResult(false, "Erreur d'envoi Firestore: $e2");
      }
    }

    if (!updateSuccess) {
      return const DemandeResult(
          false, "Impossible d'enregistrer la demande sur le serveur.");
    }

    try {
      final targetAdmin = group.creatorId.isNotEmpty
          ? group.creatorId
          : (group.members.isNotEmpty ? group.members.first : '');

      if (targetAdmin.isNotEmpty && targetAdmin != currentUid) {
        await _db.collection('notifications').add({
          'toUid': targetAdmin,
          'fromUid': currentUid,
          'type': 'group_request',
          'postId': group.id,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}

    return const DemandeResult(true, "Demande envoyée à l'administrateur !");
  }

  /// Annuler une demande d'adhésion envoyée
  Future<void> annulerDemande(String groupId) => _groups.doc(groupId).set({
        'pendingRequests': FieldValue.arrayRemove([uid]),
      }, SetOptions(merge: true));

  /// Le créateur accepte la demande d'un membre
  Future<void> accepterDemande(GroupModel group, String applicantUid) async {
    await _groups.doc(group.id).set({
      'pendingRequests': FieldValue.arrayRemove([applicantUid]),
      'members': FieldValue.arrayUnion([applicantUid]),
    }, SetOptions(merge: true));

    // Notification à l'utilisateur accepté
    await _db.collection('notifications').add({
      'toUid': applicantUid,
      'fromUid': uid,
      'type': 'group_accepted',
      'postId': group.id,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Le créateur refuse la demande d'un membre
  Future<void> refuserDemande(String groupId, String applicantUid) =>
      _groups.doc(groupId).set({
        'pendingRequests': FieldValue.arrayRemove([applicantUid]),
      }, SetOptions(merge: true));

  /// Quitter un groupe (pour un membre)
  Future<void> quitter(String id) =>
      _groups.doc(id).update({'members': FieldValue.arrayRemove([uid])});

  /// Exclure / retirer un membre du groupe (pour le créateur)
  Future<void> retirerMembre(String groupId, String memberUid) =>
      _groups.doc(groupId).update({'members': FieldValue.arrayRemove([memberUid])});

  /// Supprime le groupe et tous ses messages.
  Future<void> supprimer(String id) async {
    final msgs = await _groups.doc(id).collection('messages').get();
    final batch = _db.batch();
    for (final d in msgs.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_groups.doc(id));
    await batch.commit();
  }

  // ───────────── Messages ─────────────

  Stream<List<GroupMessage>> messages(String id) => _groups
      .doc(id)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(GroupMessage.fromDoc).toList());

  Future<void> envoyer(
    String id,
    String text, {
    String? fileName,
    Uint8List? fileBytes,
    String? fileType,
  }) =>
      _groups.doc(id).collection('messages').add({
        'senderId': uid,
        'text': text,
        'fileName': fileName,
        'fileBase64': fileBytes != null ? base64Encode(fileBytes) : null,
        'fileType': fileType,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> supprimerMessage(String groupId, String messageId) => _groups
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .delete();
}
