import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../../../theme/app_theme.dart';

class TypeBadge extends StatelessWidget {
  final PostModel post;
  const TypeBadge({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.type == 'publication') return const SizedBox.shrink();
    final texte = post.categorie.isEmpty
        ? libelleTypePost(post.type)
        : '${libelleTypePost(post.type)} · ${post.categorie}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.mintContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconeTypePost(post.type),
                size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            Text(texte,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }
}