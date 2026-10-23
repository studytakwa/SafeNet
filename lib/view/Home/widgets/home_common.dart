import 'package:flutter/material.dart';

/// Couleurs de l'écran d'accueil (reprises de la maquette).
class HomeColors {
  static const bg = Color(0xFFF4F7FB);
  static const brand = Color(0xFF156A7A);
  static const ink = Color(0xFF12303A);
  static const mute = Color(0xFF6B8088);
  static const soft = Color(0xFFD9F2EE);
  static const line = Color(0xFFE6EDF2);
  static const input = Color(0xFFF1F5F9);
  static const blue = Color(0xFF7CC6D6);
  static const purple = Color(0xFFB9A3E0);
  static const mint = Color(0xFFD6F3EE);
  static const teal = Color(0xFF2A93A6);
}

/// Carte blanche arrondie utilisée partout.
class HomeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const HomeCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeColors.line),
      ),
      child: child,
    );
  }
}

/// Avatar rond avec une lettre, et un point "en ligne" optionnel.
class Avatar extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;
  final bool online;

  const Avatar({
    super.key,
    required this.letter,
    this.color = HomeColors.blue,
    this.size = 40,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final onDark = color == HomeColors.teal;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: color,
          child: Text(
            letter,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.38,
              color: onDark ? Colors.white : HomeColors.ink,
            ),
          ),
        ),
        if (online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: HomeColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}