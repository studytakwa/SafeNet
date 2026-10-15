import 'package:flutter/material.dart';

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

              // Blasa lel logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.shield, size: 60),
                // Ba3d ma ykoun 3andek el logo, badel el child b:
                // child: Image.asset('assets/logo.png'),
              ),

              const SizedBox(height: 24),

              // Ism el app
              const Text(
                'SafeNet',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(flex: 3),

              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: yemchi lel page mta3 connexion
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
                    // TODO: yemchi lel page mta3 inscription
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