import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import 'leaderboard_view.dart';

class PlayQuizView extends StatefulWidget {
  final Quiz quiz;
  const PlayQuizView({super.key, required this.quiz});

  @override
  State<PlayQuizView> createState() => _PlayQuizViewState();
}

class _PlayQuizViewState extends State<PlayQuizView> {
  final _controller = QuizController();
  final _reponses = <int>[];
  int _index = 0;
  int? _choix;
  bool _termine = false;
  int _score = 0;

  Future<void> _valider() async {
    _reponses.add(_choix!);
    if (_index < widget.quiz.questions.length - 1) {
      setState(() {
        _index++;
        _choix = null;
      });
    } else {
      final score = _controller.calculerScore(widget.quiz, _reponses);
      await _controller.enregistrerTentative(widget.quiz, score);
      setState(() {
        _score = score;
        _termine = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    if (_termine) return _resultat(quiz);

    final q = quiz.questions[_index];
    return Scaffold(
      appBar: AppBar(title: Text(quiz.titre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_index + 1) / quiz.questions.length),
            const SizedBox(height: 8),
            Text('Question ${_index + 1} / ${quiz.questions.length}'),
            const SizedBox(height: 16),
            Text(q.texte,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (int i = 0; i < q.options.length; i++)
              Card(
                color: _choix == i
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  title: Text(q.options[i]),
                  onTap: () => setState(() => _choix = i),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _choix == null ? null : _valider,
                child: Text(_index == quiz.questions.length - 1
                    ? 'Terminer'
                    : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultat(Quiz quiz) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
            const SizedBox(height: 12),
            Text('$_score / ${quiz.questions.length}',
                style:
                const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LeaderboardView(quiz: quiz))),
              child: const Text('Voir le classement'),
            ),
          ],
        ),
      ),
    );
  }
}