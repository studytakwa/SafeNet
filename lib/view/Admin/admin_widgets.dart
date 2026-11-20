import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../Home/widgets/type_badge.dart';
import '../social/user_builder.dart';
Color couleurStatut(String statut) {
  switch (statut) {
    case 'approved':
      return const Color(0xFF10B981); // Green
    case 'rejected':
      return const Color(0xFFEF4444); // Red
    case 'pending':
    default:
      return const Color(0xFFF59E0B); // Amber
  }
}
String libelleStatut(String statut) {
  switch (statut) {
    case 'approved':
      return 'Acceptée';
    case 'rejected':
      return 'Refusée';
    case 'pending':
    default:
      return 'En attente';
  }
}
String dateComplete(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} à ${two(d.hour)}:${two(d.minute)}';
}

/// Carte de statistique pour le tableau de bord administrateur.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HomeColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: HomeColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de publication spéciale pour l'espace administrateur.
class AdminPostCard extends StatelessWidget {
  final PostModel post;
  final List<Widget>? actions;

  const AdminPostCard({
    super.key,
    required this.post,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final hasBadge = post.type != 'publication';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HomeColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(uid: post.authorId, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserName(
                        uid: post.authorId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        dateComplete(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: HomeColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: couleurStatut(post.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    libelleStatut(post.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: couleurStatut(post.status),
                    ),
                  ),
                ),
              ],
            ),
            if (hasBadge) ...[
              const SizedBox(height: 10),
              TypeBadge(post: post),
            ],
            if (post.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.text,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),
            ],
            if (post.imageBase64 != null && post.imageBase64!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(post.imageBase64!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
            if (post.rejectionReason != null &&
                post.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Text(
                  'Motif du refus : ${post.rejectionReason}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
