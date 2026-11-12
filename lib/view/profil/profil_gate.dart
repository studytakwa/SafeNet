import 'package:flutter/material.dart';

import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
import '../../services/auth_service.dart';
import '../Home/home_screen.dart';
import 'modifier_profil_page.dart';

class ProfilGate extends StatelessWidget {
  const ProfilGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfilController();

    return StreamBuilder<ProfilModel>(
      stream: controller.suivreProfil(controller.uidCourant),
      builder: (context, instantane) {
        if (instantane.hasError) {
          return const Scaffold(
            body: Center(child: Text('Impossible de charger le profil.')),
          );
        }
        if (!instantane.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profil = instantane.data!;

        if (profil.bloque) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AuthService().seDeconnecter();
          });

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Ce compte a été bloqué par l\'administrateur.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (profil.motifBlocage != null && profil.motifBlocage!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Motif : ${profil.motifBlocage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => AuthService().seDeconnecter(),
                      child: const Text('Se déconnecter'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Pas encore de nom : formulaire obligatoire de création du profil
        if (profil.nom.isEmpty) {
          return ModifierProfilPage(profil: profil, creation: true);
        }

        // Profil configuré : redirection vers l'écran d'accueil
        return const HomeScreen();
      },
    );
  }
}
