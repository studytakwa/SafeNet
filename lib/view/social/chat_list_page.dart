import 'package:flutter/material.dart';
import '../../controllers/social_controller.dart';
import '../../models/social_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../posts/post_card.dart' show formatDate;
import 'chat_page.dart';
import 'user_builder.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SocialController();
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: s.mesConversations(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les conversations : ${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune conversation pour le moment.\nOuvrez le profil d\'un ami pour lui envoyer un message !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HomeColors.mute, height: 1.4),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final chat = list[i];
              final other = chat.other(s.uid);
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
                  leading: UserAvatar(uid: other),
                  title: UserName(
                    uid: other,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: Text(
                    formatDate(chat.lastAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: HomeColors.mute,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatPage(otherUid: other)),
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
