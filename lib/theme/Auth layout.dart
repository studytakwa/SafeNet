import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nom affiché du réseau (à modifier ici une seule fois).
const String nomReseau = 'SafeNet';

const Color _bordure = Color(0xFFE6EDF5);
const Color _erreur = Color(0xFFDC2626);

/// Champ de saisie en pilule, comme la barre de recherche de l'accueil.
InputDecoration champDecoration({
  required String label,
  required IconData icone,
  Widget? suffixe,
}) {
  OutlineInputBorder bord(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icone, color: AppColors.primary, size: 22),
    suffixIcon: suffixe,
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

/// Bouton principal : pilule bleu canard (comme « Publier »).
ButtonStyle styleBoutonPrincipal() => ElevatedButton.styleFrom(
  backgroundColor: AppColors.primaryDark,
  foregroundColor: Colors.white,
  elevation: 0,
  minimumSize: const Size.fromHeight(52),
  shape: const StadiumBorder(),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
);

/// Bouton secondaire : pilule contour bleu océan (comme « Suivre »).
ButtonStyle styleBoutonSecondaire() => OutlinedButton.styleFrom(
  foregroundColor: AppColors.primaryDark,
  side: const BorderSide(color: AppColors.primary, width: 1.5),
  minimumSize: const Size.fromHeight(52),
  shape: const StadiumBorder(),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
);

/// Logo : carré arrondi bleu canard avec bulle de discussion.
class LogoReseau extends StatelessWidget {
  final double taille;
  const LogoReseau({super.key, this.taille = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(taille * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/logo.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          size: taille * 0.5,
        ),
      ),
    );
  }
}

/// Avatar à anneau dégradé, comme les stories de l'accueil.
class AvatarStory extends StatelessWidget {
  final String lettre;
  final Color couleur;
  final double taille;
  const AvatarStory({
    super.key,
    required this.lettre,
    required this.couleur,
    this.taille = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          backgroundColor: couleur,
          child: Text(
            lettre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Squelette commun des pages d'authentification.
class AuthLayout extends StatelessWidget {
  final Widget child;
  final bool afficherRetour;
  const AuthLayout({super.key, required this.child, this.afficherRetour = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Halos décoratifs doux
          Positioned(
            top: -90,
            right: -70,
            child: _halo(260, AppColors.accent.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _halo(300, AppColors.secondary.withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 220,
            left: -60,
            child: _halo(140, AppColors.mintContainer),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: child,
                    ),
                  ),
                ),
                if (afficherRetour)
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(
                        side: BorderSide(color: _bordure),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.primaryDark,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _halo(double d, Color c) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

/// Carte blanche arrondie, comme les cartes de l'accueil.
class CarteAuth extends StatelessWidget {
  final Widget child;
  const CarteAuth({super.key, required this.child});

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

/// En-tête : logo + nom du réseau.
class EnteteMarque extends StatelessWidget {
  final double tailleLogo;
  const EnteteMarque({super.key, this.tailleLogo = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogoReseau(taille: tailleLogo),
        const SizedBox(height: 14),
        const Text(
          nomReseau,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}