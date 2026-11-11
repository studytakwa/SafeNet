import 'package:flutter/material.dart';
import '../../controllers/social_controller.dart';
import '../../models/social_model.dart';
import '../../theme/app_theme.dart';
import 'chat_page.dart';

/// Bouton d'invitation/amitié à placer sur le profil d'un autre utilisateur.
class FriendButton extends StatefulWidget {
  final String otherUid;
  const FriendButton({super.key, required this.otherUid});

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  final _s = SocialController();
  late final Stream<Relation> _stream = _s.relation(widget.otherUid);
  bool _chargement = false;

  Future<void> _traiter(Future<void> Function() action) async {
    if (_chargement) return;
    setState(() => _chargement = true);
    try {
      await action();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _confirmRemove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet ami ?'),
        content: const Text('Voulez-vous vraiment retirer cet ami de votre liste ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) await _traiter(() => _s.retirer(widget.otherUid));
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.otherUid;
    return StreamBuilder<Relation>(
      stream: _stream,
      builder: (context, snap) {
        final r = snap.data ?? Relation.none;

        if (_chargement) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2E8F0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: null,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryDark,
              ),
            ),
          );
        }

        switch (r) {
          case Relation.none:
            return FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _traiter(() => _s.envoyerDemande(other)),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Envoyer une invitation',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            );

          case Relation.sent:
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2E8F0),
                foregroundColor: const Color(0xFF64748B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _traiter(() => _s.retirer(other)),
              icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF64748B)),
              label: const Text('Invitation envoyée',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            );

          case Relation.received:
            return Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _traiter(() => _s.accepter(other)),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Accepter'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _traiter(() => _s.retirer(other)),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Refuser'),
                ),
              ],
            );

          case Relation.friends:
            return Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _confirmRemove,
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('Amis'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatPage(otherUid: other)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Message'),
                ),
              ],
            );
        }
      },
    );
  }
}
