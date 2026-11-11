import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionQuiz {
  final String texte;
  final List<String> options;
  final int bonneReponse;

  QuestionQuiz({
    required this.texte,
    required this.options,
    required this.bonneReponse,
  });

  Map<String, dynamic> toMap() => {
    'texte': texte,
    'options': options,
    'bonneReponse': bonneReponse,
  };

  factory QuestionQuiz.fromMap(Map<String, dynamic> m) => QuestionQuiz(
    texte: m['texte'] ?? '',
    options: List<String>.from(m['options'] ?? []),
    bonneReponse: m['bonneReponse'] ?? 0,
  );
}

class Quiz {
  final String id;
  final String createurId;
  final String createurNom;
  final String titre;
  final String categorie;
  final String code;
  final String? groupeId;
  final List<QuestionQuiz> questions;
  final List<String> participants;
  final DateTime date;

  Quiz({
    required this.id,
    required this.createurId,
    required this.createurNom,
    required this.titre,
    required this.categorie,
    required this.code,
    required this.questions,
    required this.participants,
    required this.date,
    this.groupeId,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> m) => Quiz(
    id: id,
    createurId: m['createurId'] ?? '',
    createurNom: m['createurNom'] ?? '',
    titre: m['titre'] ?? '',
    categorie: m['categorie'] ?? '',
    code: m['code'] ?? '',
    groupeId: m['groupeId'],
    questions: (m['questions'] as List? ?? [])
        .map((q) => QuestionQuiz.fromMap(Map<String, dynamic>.from(q)))
        .toList(),
    participants: List<String>.from(m['participants'] ?? []),
    date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

class TentativeQuiz {
  final String userId;
  final String userNom;
  final int score;
  final int total;
  final DateTime date;

  TentativeQuiz({
    required this.userId,
    required this.userNom,
    required this.score,
    required this.total,
    required this.date,
  });

  factory TentativeQuiz.fromMap(Map<String, dynamic> m) => TentativeQuiz(
    userId: m['userId'] ?? '',
    userNom: m['userNom'] ?? '',
    score: m['score'] ?? 0,
    total: m['total'] ?? 0,
    date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}