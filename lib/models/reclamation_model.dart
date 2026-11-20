import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationModel {
  final String id;
  final String auteurUid;
  final String cibleId; // ID du post ou du profil
  final String cibleType; // 'post' ou 'profil'
  final String motif;
  final DateTime createdAt;
  final String statut; // 'pending' | 'resolved'

  const ReclamationModel({
    required this.id,
    required this.auteurUid,
    required this.cibleId,
    required this.cibleType,
    required this.motif,
    required this.createdAt,
    this.statut = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'auteurUid': auteurUid,
      'cibleId': cibleId,
      'cibleType': cibleType,
      'motif': motif,
      'createdAt': FieldValue.serverTimestamp(),
      'statut': statut,
    };
  }

  factory ReclamationModel.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>? ?? {};
    return ReclamationModel(
      id: d.id,
      auteurUid: m['auteurUid'] ?? '',
      cibleId: m['cibleId'] ?? '',
      cibleType: m['cibleType'] ?? 'post',
      motif: m['motif'] ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statut: m['statut'] ?? 'pending',
    );
  }
}
