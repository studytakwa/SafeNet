import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';

class LeaderboardView extends StatelessWidget {
  final Quiz quiz;
  LeaderboardView({super.key, required this.quiz});
  final _controller = QuizController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classement : ${quiz.titre}')),
      body: StreamBuilder<List<TentativeQuiz>>(
        stream: _controller.classement(quiz.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Personne n\'a encore joué'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(list[i].userNom),
              trailing: Text('${list[i].score} / ${list[i].total}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}