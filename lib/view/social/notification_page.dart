import 'package:flutter/material.dart';
import '../../controllers/social_controller.dart';
import '../../models/social_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../posts/post_card.dart' show formatDate;
import '../profil/profil_page.dart';
import 'amis_page.dart';
import 'user_builder.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _s = SocialController();
  late final Stream<List<NotifModel>> _stream = _s.notifications();

  @override
  void dispose() {
    _s.marquerLues();
    super.dispose();
  }

  String _texte(String type) {
    switch (type) {
      case 'friend_request':
        return "vous a envoyé une demande d'ami";
      case 'friend_accepted':
        return "a accepté votre demande d'ami";
      case 'like':
        return 'a aimé votre publication';
      case 'comment':
        return 'a commenté votre publication';
      default:
        return 'a interagi avec vous';
    }
  }

  void _ouvrir(NotifModel n) {
    final isFriend = n.type == 'friend_request' || n.type == 'friend_accepted';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isFriend ? const AmisPage() : const ProfilPage(),
      ),
    );
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
          'Notifications',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<NotifModel>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les notifications : ${snap.error}',
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
                  'Aucune notification pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HomeColors.mute),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final n = list[i];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: n.read ? Colors.white : AppColors.mintContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: HomeColors.line),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: UserAvatar(uid: n.fromUid),
                  title: Row(
                    children: [
                      Flexible(
                        child: UserName(
                          uid: n.fromUid,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _texte(n.type),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatDate(n.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: HomeColors.mute,
                      ),
                    ),
                  ),
                  trailing: n.type == 'friend_request'
                      ? _BoutonAccepterNotif(fromUid: n.fromUid, socialController: _s)
                      : null,
                  onTap: () => _ouvrir(n),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BoutonAccepterNotif extends StatefulWidget {
  final String fromUid;
  final SocialController socialController;
  const _BoutonAccepterNotif({
    required this.fromUid,
    required this.socialController,
  });

  @override
  State<_BoutonAccepterNotif> createState() => _BoutonAccepterNotifState();
}

class _BoutonAccepterNotifState extends State<_BoutonAccepterNotif> {
  bool _enCours = false;

  Future<void> _accepter() async {
    if (_enCours) return;
    setState(() => _enCours = true);
    try {
      await widget.socialController.accepter(widget.fromUid);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Relation>(
      stream: widget.socialController.relation(widget.fromUid),
      builder: (context, snap) {
        final r = snap.data ?? Relation.none;

        if (r == Relation.friends) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mintContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 16),
                SizedBox(width: 4),
                Text(
                  'Amis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          );
        }

        return FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          onPressed: _enCours ? null : _accepter,
          icon: _enCours
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 16),
          label: const Text('Accepter'),
        );
      },
    );
  }
}
