import 'package:flutter/material.dart';
import 'app_theme.dart';

const Color _bordure = Color(0xFFE6EDF5);
const Color _erreur = Color(0xFFDC2626);

/// Carte blanche arrondie du profil.
class CarteProfil extends StatelessWidget {
  final Widget child;
  const CarteProfil({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _bordure),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Champ de saisie du profil (arrondi réglable pour la bio).
InputDecoration decorationChampProfil({
  required String label,
  required IconData icone,
  double rayon = 30,
  bool alignerLabel = false,
}) {
  OutlineInputBorder bord(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(rayon),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    alignLabelWithHint: alignerLabel,
    labelText: label,
    prefixIcon: Icon(icone, color: AppColors.primary, size: 22),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: bord(_bordure),
    enabledBorder: bord(_bordure),
    focusedBorder: bord(AppColors.primary, 1.5),
    errorBorder: bord(_erreur),
    focusedErrorBorder: bord(_erreur, 1.5),
    labelStyle: const TextStyle(color: Colors.black54),
    floatingLabelStyle: const TextStyle(color: AppColors.primaryDark),
  );
}

ButtonStyle styleBoutonProfilPrincipal() => ElevatedButton.styleFrom(
  backgroundColor: AppColors.primaryDark,
  foregroundColor: Colors.white,
  elevation: 0,
  minimumSize: const Size.fromHeight(52),
  shape: const StadiumBorder(),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
);

ButtonStyle styleBoutonProfilSecondaire() => OutlinedButton.styleFrom(
  foregroundColor: AppColors.primaryDark,
  side: const BorderSide(color: AppColors.primary, width: 1.5),
  minimumSize: const Size.fromHeight(52),
  shape: const StadiumBorder(),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
);

/// Avatar de profil : anneau dégradé (comme les stories) + photo ou initiale.
class AvatarProfil extends StatelessWidget {
  final ImageProvider? image;
  final String initiale;
  final double taille;
  final VoidCallback? onTap;
  final bool badgeCamera;

  const AvatarProfil({
    super.key,
    this.image,
    this.initiale = '',
    this.taille = 116,
    this.onTap,
    this.badgeCamera = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: taille,
      height: taille,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.mintContainer,
          backgroundImage: image,
          child: image != null
              ? null
              : (initiale.isNotEmpty
              ? Text(
            initiale.toUpperCase(),
            style: TextStyle(
              fontSize: taille * 0.36,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          )
              : Icon(Icons.person_rounded,
              size: taille * 0.45, color: AppColors.primary)),
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (badgeCamera)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 3),
                ),
                child: const Icon(Icons.photo_camera_outlined,
                    color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

/// En-tête de profil : bandeau dégradé lagon → lavande avec l'avatar
/// qui déborde en dessous, comme les visuels de l'accueil.
class EnteteProfil extends StatelessWidget {
  final Widget avatar;
  final double tailleAvatar;
  final String? titre;
  final bool afficherRetour;

  const EnteteProfil({
    super.key,
    required this.avatar,
    this.tailleAvatar = 116,
    this.titre,
    this.afficherRetour = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (afficherRetour)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: AppColors.surface,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.primaryDark,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ),
                      if (titre != null)
                        Text(
                          titre!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 190 - tailleAvatar / 2,
              child: avatar,
            ),
          ],
        ),
        SizedBox(height: tailleAvatar / 2 + 16),
      ],
    );
  }
}