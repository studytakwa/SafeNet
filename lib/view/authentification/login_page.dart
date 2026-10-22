import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import 'package:safenet/theme/Auth layout.dart';
import 'connexion.dart';
import 'inscription.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EnteteMarque(tailleLogo: 84),
          const SizedBox(height: 28),
          CarteAuth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rangée d'avatars façon « stories
                const SizedBox(height: 22),
                const Text(
                  'Bienvenue !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Retrouvez vos amis, partagez vos moments\net restez connecté en toute sécurité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  style: styleBoutonPrincipal(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnexionPage()),
                    );
                  },
                  child: const Text('Se connecter'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: styleBoutonSecondaire(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Inscription()),
                    );
                  },
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}