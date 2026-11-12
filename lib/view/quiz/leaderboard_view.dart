import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';

class LeaderboardView extends StatelessWidget {
  final Quiz quiz;
  LeaderboardView({super.key, required this.quiz});
  final _controller = QuizController();

  Color _rankColor(int rank) {
    if (rank == 0) return const Color(/* Gold */ 0xFFFFD700);
    if (rank == 1) return const Color(/* Silver */ 0xFFC0C0C0);
    if (rank == 2) return const Color(/* Bronze */ 0xFFCD7F32);
    return AppColors.mintContainer;
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
        title: Text(
          'Classement : ${quiz.titre}',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<TentativeQuiz>>(
        stream: _controller.classement(quiz.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.mintContainer,
                      child: const Icon(Icons.emoji_events_outlined,
                          size: 36, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun participant pour le moment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Soyez le premier à tenter ce quiz !',
                      style: TextStyle(color: HomeColors.mute),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];
              final isTopThree = i < 3;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: HomeColors.line),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: _rankColor(i),
                    child: isTopThree
                        ? Icon(
                            Icons.emoji_events_rounded,
                            size: 18,
                            color: i == 0 ? Colors.white : AppColors.primaryDark,
                          )
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                  ),
                  title: Text(
                    item.userNom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mintContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.score} / ${item.total}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        fontSize: 13,
                      ),
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
