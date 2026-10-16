import 'package:flutter/material.dart';
import 'inscription.dart';
import 'connexion.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Image.asset(
                'assets/logo.jpg',
                width: 280,
                height: 280,
              ),

              const Spacer(flex: 3),

              // Bouton Se connecter (pas encore fait)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnexionPage()),
                    );
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