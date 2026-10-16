import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'inscription.dart';
import 'connexion.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo dans une carte arrondie
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Bouton Se connecter (réservé pour plus tard)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
<<<<<<< HEAD
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnexionPage()),
                    );
=======
                    // TODO: connexion
>>>>>>> e5b49ffe719b4ff01757d2874e3ca5e5d6e26a4c
                  },
                  child: const Text('Se connecter'),
                ),
              ),

              const SizedBox(height: 12),

              // Bouton Créer un compte
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Inscription()),
                    );
                  },
                  child: const Text('Créer un compte'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
