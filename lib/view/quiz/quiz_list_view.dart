import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import 'create_quiz_view.dart';
import 'play_quiz_view.dart';
import 'leaderboard_view.dart';

class QuizListView extends StatelessWidget {
  QuizListView({super.key});
  final _controller = QuizController();

  Future<void> _rejoindre(BuildContext context) async {
    final codeCtrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rejoindre un quiz'),
        content: TextField(
          controller: codeCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Code du quiz'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, codeCtrl.text),
              child: const Text('Rejoindre')),
        ],
      ),
    );
    if (code == null || code.trim().isEmpty) return;
    final quiz = await _controller.rejoindre(code);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(quiz == null ? 'Code invalide' : 'Quiz "${quiz.titre}" ajouté'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz entre amis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Rejoindre avec un code',
            onPressed: () => _rejoindre(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateQuizView())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Quiz>>(
        stream: _controller.mesQuiz(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erreur : ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizList = snap.data!;
          if (quizList.isEmpty) {
            return const Center(
                child: Text('Aucun quiz. Crée-en un ou rejoins un ami !'));
          }
          return ListView.builder(
            itemCount: quizList.length,
            itemBuilder: (_, i) {
              final q = quizList[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(q.titre),
                  subtitle: Text(
                      '${q.categorie} • ${q.questions.length} questions\n'
                          'Par ${q.createurNom} • Code : ${q.code}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.emoji_events),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LeaderboardView(quiz: q))),
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PlayQuizView(quiz: q))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}