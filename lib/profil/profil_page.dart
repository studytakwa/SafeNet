import 'package:flutter/material.dart';

import '../models/profil.dart';
import '../services/profil_service.dart';
import 'modifier_profil_page.dart';

class ProfilPage extends StatelessWidget {
  // uid vide = mon propre profil ; sinon, profil d'un autre utilisateur
  final String? uid;
  const ProfilPage({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final service = ProfilService();
    final idAffiche = uid ?? service.uidCourant;
    final estMonProfil = idAffiche == service.uidCourant;

    return Scaffold(
      appBar: AppBar(title: Text(estMonProfil ? 'Mon profil' : 'Profil')),
      body: StreamBuilder<Profil>(
        stream: service.suivreProfil(idAffiche),
        builder: (context, instantane) {
          if (instantane.hasError) {
            return const Center(child: Text('Impossible de charger le profil.'));
          }
          if (!instantane.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profil = instantane.data!;
          final photo = profil.photoOctets;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photo != null ? MemoryImage(photo) : null,
                  child: photo != null ? null : const Icon(Icons.person, size: 56),
                ),
                const SizedBox(height: 16),
                Text(
                  profil.nom.isEmpty ? 'Nom non renseigné' : profil.nom,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profil.bio.isEmpty ? 'Aucune bio pour le moment.' : profil.bio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (estMonProfil)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModifierProfilPage(profil: profil),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier le profil'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}