import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_model.dart';

class QuizController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _quiz => _db.collection('quiz');

  String get _uid => _auth.currentUser!.uid;
  String get _nom =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'Utilisateur';

  String _genererCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// Crée un quiz et renvoie son code d'invitation.
  Future<String> creerQuiz({
    required String titre,
    required String categorie,
    required List<QuestionQuiz> questions,
    String? groupeId,
  }) async {
    final code = _genererCode();
    await _quiz.add({
      'createurId': _uid,
      'createurNom': _nom,
      'titre': titre,
      'categorie': categorie,
      'code': code,
      'groupeId': groupeId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'participants': [_uid],
      'date': FieldValue.serverTimestamp(),
    });
    return code;
  }

  /// Quiz créés par moi ou rejoints via un code.
  Stream<List<Quiz>> mesQuiz() {
    return _quiz.where('participants', arrayContains: _uid).snapshots().map((s) {
      final list = s.docs.map((d) => Quiz.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Rejoindre un quiz avec le code d'un ami. Renvoie null si le code est invalide.
  Future<Quiz?> rejoindre(String code) async {
    final snap = await _quiz
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    await doc.reference.update({
      'participants': FieldValue.arrayUnion([_uid]),
    });
    return Quiz.fromMap(doc.id, doc.data());
  }

  int calculerScore(Quiz quiz, List<int> reponses) {
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (i < reponses.length && reponses[i] == quiz.questions[i].bonneReponse) {
        score++;
      }
    }
    return score;
  }

  /// Une seule tentative enregistrée par utilisateur (la dernière).
  Future<void> enregistrerTentative(Quiz quiz, int score) {
    return _quiz.doc(quiz.id).collection('tentatives').doc(_uid).set({
      'userId': _uid,
      'userNom': _nom,
      'score': score,
      'total': quiz.questions.length,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TentativeQuiz>> classement(String quizId) {
    return _quiz
        .doc(quizId)
        .collection('tentatives')
        .orderBy('score', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TentativeQuiz.fromMap(d.data())).toList());
  }
}