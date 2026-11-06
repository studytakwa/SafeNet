import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Couleurs de l'application SafeNet unifiées avec [AppColors].
class HomeColors {
  static const bg = AppColors.background;
  static const brand = AppColors.primaryDark;
  static const ink = Color(0xFF1E293B);
  static const mute = Color(0xFF64748B);
  static const soft = AppColors.mintContainer;
  static const line = Color(0xFFE2E8F0);
  static const input = Color(0xFFF8FAFC);
  static const blue = AppColors.secondary;
  static const purple = AppColors.accent;
  static const mint = AppColors.mintContainer;
  static const teal = AppColors.primary;
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    final onDark = color == HomeColors.teal || color == HomeColors.brand;
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
