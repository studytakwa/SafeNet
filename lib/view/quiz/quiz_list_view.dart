import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import 'create_quiz_view.dart';
import 'leaderboard_view.dart';
import 'play_quiz_view.dart';

class QuizListView extends StatelessWidget {
  QuizListView({super.key});
  final _controller = QuizController();

  Future<void> _rejoindre(BuildContext context) async {
    final codeCtrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AppColors.primaryDark),
            SizedBox(width: 8),
            Text(
              'Rejoindre un quiz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: codeCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Code du quiz (ex: ABC123)',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, codeCtrl.text.trim()),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    final quiz = await _controller.rejoindre(code);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: quiz != null ? AppColors.primaryDark : Colors.redAccent,
      content: Text(
        quiz == null ? 'Code invalide ou quiz inexistant.' : 'Quiz "${quiz.titre}" ajouté !',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Quiz Éducatifs & Défis',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded, color: AppColors.primaryDark),
            tooltip: 'Rejoindre avec un code',
            onPressed: () => _rejoindre(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateQuizView()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer un quiz', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Quiz>>(
        stream: _controller.mesQuiz(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur : ${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizList = snap.data!;
          if (quizList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.mintContainer,
                      child: const Icon(Icons.quiz_rounded, size: 36, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun quiz disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Créez un quiz ou rejoignez celui d\'un ami grâce à son code !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: HomeColors.mute, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _rejoindre(context),
                      icon: const Icon(Icons.key_rounded),
                      label: const Text('Entrer un code'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
            itemCount: quizList.length,
            itemBuilder: (_, i) {
              final q = quizList[i];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: HomeColors.line),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlayQuizView(quiz: q)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.mintContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school_rounded, color: AppColors.primaryDark, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.titre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: HomeColors.line),
                                        ),
                                        child: Text(
                                          q.categorie,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${q.questions.length} question${q.questions.length > 1 ? 's' : ''}',
                                        style: const TextStyle(fontSize: 12, color: HomeColors.mute),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                              tooltip: 'Classement',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LeaderboardView(quiz: q)),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Par ${q.createurNom}',
                              style: const TextStyle(fontSize: 12, color: HomeColors.mute),
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: q.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Code ${q.code} copié !')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mintContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 12, color: AppColors.primaryDark),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Code : ${q.code}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
