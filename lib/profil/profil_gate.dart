import 'package:flutter/material.dart';

import '../models/profil.dart';
import '../services/profil_service.dart';
import 'modifier_profil_page.dart';
import 'profil_page.dart';

class ProfilGate extends StatelessWidget {
  const ProfilGate({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProfilService();

    return StreamBuilder<Profil>(
      stream: service.suivreProfil(service.uidCourant),
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

        // Pas encore de nom : formulaire de création du profil
        if (profil.nom.isEmpty) {
          return ModifierProfilPage(profil: profil, creation: true);
        }
        // Profil déjà créé : page "Mon profil"
        return const ProfilPage();
      },
    );
  }
}