import 'package:flutter/material.dart';

import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
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
