import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profil.dart';
import '../services/profil_service.dart';

class ModifierProfilPage extends StatefulWidget {
  final Profil profil;
  final bool creation; // true = première création du profil
  const ModifierProfilPage({super.key, required this.profil, this.creation = false});
  @override
  State<ModifierProfilPage> createState() => _EtatModifierProfil();
}

class _EtatModifierProfil extends State<ModifierProfilPage> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _service = ProfilService();
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
    try {
      await _service.enregistrerProfil(
        nom: _ctrlNom.text.trim(),
        bio: _ctrlBio.text.trim(),
        photo: _nouvellePhoto, uid: '',
      );
      if (!mounted) return;
      if (!widget.creation) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'enregistrer le profil. Réessayez.")),
      );
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoActuelle = widget.profil.photoOctets;
    final ImageProvider? image = _nouvellePhoto != null
        ? MemoryImage(_nouvellePhoto!)
        : (photoActuelle != null ? MemoryImage(photoActuelle) : null);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.creation,
        title: Text(widget.creation ? 'Créer mon profil' : 'Modifier le profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _cleFormulaire,
          child: Column(
            children: [
              GestureDetector(
                onTap: _choisirPhoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: image,
                  child: image == null ? const Icon(Icons.person, size: 56) : null,
                ),
              ),
              TextButton.icon(
                onPressed: _choisirPhoto,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Changer la photo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ctrlNom,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  final texte = v?.trim() ?? '';
                  if (texte.isEmpty) return 'Entrez votre nom';
                  if (texte.length < 2) return 'Nom trop court';
                  if (texte.length > 30) return '30 caractères maximum';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ctrlBio,
                maxLines: 4,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.edit_note),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
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
                      : Text(widget.creation ? 'Créer mon profil' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}