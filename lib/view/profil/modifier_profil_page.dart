import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
import '../../theme/app_theme.dart';
import 'package:safenet/theme/Profil widgets.dart';

class ModifierProfilPage extends StatefulWidget {
  final ProfilModel profil;
  final bool creation; // true = première création du profil
  const ModifierProfilPage({super.key, required this.profil, this.creation = false});

  @override
  State<ModifierProfilPage> createState() => _EtatModifierProfil();
}

class _EtatModifierProfil extends State<ModifierProfilPage> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controller = ProfilController();
  final _selecteur = ImagePicker();

  late final TextEditingController _ctrlNom =
  TextEditingController(text: widget.profil.nom);
  late final TextEditingController _ctrlBio =
  TextEditingController(text: widget.profil.bio);

  Uint8List? _nouvellePhoto;
  bool _enregistrement = false;

  @override
  void dispose() {
    _ctrlNom.dispose();
    _ctrlBio.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final fichier = await _selecteur.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 60,
    );
    if (fichier == null) return;
    final octets = await fichier.readAsBytes();
    setState(() => _nouvellePhoto = octets);
  }

  Future<void> _enregistrer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() => _enregistrement = true);

    final erreur = await _controller.enregistrer(
      nom: _ctrlNom.text,
      bio: _ctrlBio.text,
      photo: _nouvellePhoto,
    );

    if (!mounted) return;
    setState(() => _enregistrement = false);

    if (erreur == null) {
      if (!widget.creation) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erreur),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoActuelle = widget.profil.photoOctets;
    final ImageProvider? image = _nouvellePhoto != null
        ? MemoryImage(_nouvellePhoto!)
        : (photoActuelle != null ? MemoryImage(photoActuelle) : null);
    final nom = _ctrlNom.text.trim();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EnteteProfil(
              titre: widget.creation ? 'Créer mon profil' : 'Modifier le profil',
              afficherRetour: !widget.creation,
              avatar: AvatarProfil(
                image: image,
                initiale: nom.isNotEmpty ? nom[0] : '',
                onTap: _choisirPhoto,
                badgeCamera: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: CarteProfil(
                    child: Form(
                      key: _cleFormulaire,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.creation
                                ? 'Bienvenue ! Présentez-vous'
                                : 'Vos informations',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.creation
                                ? 'Ajoutez une photo, votre nom et une courte bio.'
                                : 'Touchez la photo pour la changer.',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _ctrlNom,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            decoration: decorationChampProfil(
                              label: 'Nom',
                              icone: Icons.person_outline,
                            ),
                            validator: (v) {
                              final texte = v?.trim() ?? '';
                              if (texte.isEmpty) return 'Entrez votre nom';
                              if (texte.length < 2) return 'Nom trop court';
                              if (texte.length > 30) {
                                return '30 caractères maximum';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ctrlBio,
                            maxLines: 4,
                            maxLength: 150,
                            decoration: decorationChampProfil(
                              label: 'Bio',
                              icone: Icons.edit_note,
                              rayon: 24,
                              alignerLabel: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: styleBoutonProfilPrincipal(),
                            onPressed: _enregistrement ? null : _enregistrer,
                            child: _enregistrement
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                                : Text(widget.creation
                                ? 'Créer mon profil'
                                : 'Enregistrer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}