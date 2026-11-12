import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
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
    if (_choix == null) return;
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
    final progress = (_index + 1) / quiz.questions.length;

    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: Text(
          quiz.titre,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.mintContainer,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_index + 1} sur ${quiz.questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HomeColors.mute,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: HomeColors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.texte,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (_, i) {
                  final estChoisi = _choix == i;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: estChoisi ? AppColors.mintContainer : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: estChoisi
                            ? AppColors.primary
                            : HomeColors.line,
                        width: estChoisi ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      onTap: () => setState(() => _choix = i),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: estChoisi
                            ? AppColors.primaryDark
                            : AppColors.background,
                        child: Text(
                          String.fromCharCode(65 + i), // A, B, C, D
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: estChoisi ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                      ),
                      title: Text(
                        q.options[i],
                        style: TextStyle(
                          fontWeight: estChoisi ? FontWeight.bold : FontWeight.normal,
                          color: estChoisi ? AppColors.primaryDark : Colors.black87,
                        ),
                      ),
                      trailing: estChoisi
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryDark)
                          : null,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _choix == null ? null : _valider,
                  child: Text(
                    _index == quiz.questions.length - 1
                        ? 'Terminer le quiz'
                        : 'Question suivante',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultat(Quiz quiz) {
    final pourcentage = (_score / quiz.questions.length * 100).toInt();

    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Résultat du Quiz',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.mintContainer,
                child: const Icon(Icons.emoji_events_rounded,
                    size: 52, color: Colors.amber),
              ),
              const SizedBox(height: 20),
              Text(
                '$_score / ${quiz.questions.length}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Score : $pourcentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LeaderboardView(quiz: quiz)),
                  ),
                  icon: const Icon(Icons.leaderboard_rounded),
                  label: const Text('Voir le classement',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour aux quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
