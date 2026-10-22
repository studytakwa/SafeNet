import 'package:cloud_firestore/cloud_firestore.dart';

class UtilisateurModel {
  final String uid;
  final String email;
  final DateTime dateNaissance;
  final DateTime? creeLe;

  UtilisateurModel({
    required this.uid,
    required this.email,
    required this.dateNaissance,
    this.creeLe,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'dateNaissance': Timestamp.fromDate(dateNaissance),
      'creeLe': creeLe != null ? Timestamp.fromDate(creeLe!) : FieldValue.serverTimestamp(),
    };
  }

  factory UtilisateurModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UtilisateurModel(
      uid: doc.id,
      email: data['email'] ?? '',
      dateNaissance: (data['dateNaissance'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creeLe: (data['creeLe'] as Timestamp?)?.toDate(),
    );
  }
}
