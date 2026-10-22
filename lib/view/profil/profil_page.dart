import 'package:flutter/material.dart';

import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
import '../../theme/app_theme.dart';
import 'modifier_profil_page.dart';
import 'package:safenet/theme/Profil widgets.dart';

class ProfilPage extends StatelessWidget {
  // uid vide = mon propre profil ; sinon, profil d'un autre utilisateur
  final String? uid;
  const ProfilPage({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final controller = ProfilController();
    final idAffiche = uid ?? controller.uidCourant;
    final estMonProfil = idAffiche == controller.uidCourant;

    return Scaffold(
      body: StreamBuilder<ProfilModel>(
        stream: controller.suivreProfil(idAffiche),
        builder: (context, instantane) {
          if (instantane.hasError) {
            return const Center(child: Text('Impossible de charger le profil.'));
          }
          if (!instantane.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final profil = instantane.data!;
          final photo = profil.photoOctets;
          final aUnNom = profil.nom.isNotEmpty;
          final aUneBio = profil.bio.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              children: [
                EnteteProfil(
                  titre: estMonProfil ? 'Mon profil' : 'Profil',
                  afficherRetour: Navigator.of(context).canPop(),
                  avatar: AvatarProfil(
                    image: photo != null ? MemoryImage(photo) : null,
                    initiale: aUnNom ? profil.nom.trim()[0] : '',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: CarteProfil(
                        child: Column(
                          children: [
                            Text(
                              aUnNom ? profil.nom : 'Nom non renseigné',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                aUneBio
                                    ? profil.bio
                                    : 'Aucune bio pour le moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: aUneBio
                                      ? const Color(0xFF1E293B)
                                      : Colors.black45,
                                  fontStyle: aUneBio
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            ),
                            if (estMonProfil) ...[
                              const SizedBox(height: 22),
                              OutlinedButton.icon(
                                style: styleBoutonProfilSecondaire(),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ModifierProfilPage(profil: profil),
                                  ),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Modifier le profil'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}