import 'package:flutter/material.dart';

import 'home_common.dart';

/// Zone "Quoi de neuf ?" avec Photo / Vidéo / Humeur / Publier.
/// Front-end seulement : les boutons ne font rien pour l'instant.
class PostComposer extends StatelessWidget {
  const PostComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Avatar(letter: 'V', color: HomeColors.purple),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Quoi de neuf, Prénom ?',
                    hintStyle: const TextStyle(color: HomeColors.mute),
                    filled: true,
                    fillColor: HomeColors.input,
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: const [
                    _Tool(icon: Icons.image_outlined, label: 'Photo'),
                    _Tool(icon: Icons.videocam_outlined, label: 'Vidéo'),
                    _Tool(icon: Icons.emoji_emotions_outlined, label: 'Humeur'),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: HomeColors.brand,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Publier',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tool({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: HomeColors.brand,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}