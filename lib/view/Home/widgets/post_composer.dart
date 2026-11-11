import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/post_controller.dart';
import '../../../controllers/profil_controller.dart';
import '../../../models/groupe_model.dart'; // kThemes
import '../../../models/post_model.dart';
import '../../../models/profil_model.dart';
import 'home_common.dart';

/// Zone "Quoi de neuf ?" : type + texte + photo + humeur + Publier.
class PostComposer extends StatefulWidget {
  const PostComposer({super.key});

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  /// Limite de sécurité : un document Firestore ne peut pas dépasser 1 Mo.
  static const _maxBytes = 700 * 1024;

  final _ctrl = TextEditingController();
  final _posts = PostController();
  final _picker = ImagePicker();
  late final Stream<ProfilModel>? _profilStream;

  Uint8List? _imageBytes;
  bool _loading = false;
  String _type = 'publication';
  String _categorie = kThemes.first;

  @override
  void initState() {
    super.initState();
    final pc = ProfilController();
    final uid = pc.uidCourant;
    _profilStream = uid.isNotEmpty ? pc.suivreProfil(uid) : null;
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _indice(String prenom) {
    switch (_type) {
      case 'astuce':
        return 'Partage une astuce utile…';
      case 'note':
        return 'Écris ta note de cours…';
      case 'question':
        return 'Pose ta question à la communauté…';
      default:
        return prenom.isEmpty ? 'Quoi de neuf ?' : 'Quoi de neuf, $prenom ?';
    }
  }

  Future<void> _pickImage() async {
    // La photo est réduite et compressée pour tenir dans Firestore.
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 60,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > _maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Image trop lourde, choisissez-en une autre.')),
        );
      }
      return;
    }
    setState(() => _imageBytes = bytes);
  }

  void _pickMood() {
    const emojis = [
      '😀', '😂', '😍', '🥰', '😎', '🤔', '😢', '😡', '👍', '🙏', '🎉', '❤️'
    ];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in emojis)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _ctrl.text = '${_ctrl.text}$e';
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(e, style: const TextStyle(fontSize: 30)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _publier(String nom) async {
    setState(() => _loading = true);
    try {
      await _posts.publier(
        authorName: nom,
        text: _ctrl.text.trim(),
        imageBytes: _imageBytes,
        type: _type,
        categorie: _type == 'publication' ? '' : _categorie,
      );
      _ctrl.clear();
      setState(() => _imageBytes = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la publication : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfilModel>(
      stream: _profilStream,
      builder: (context, snap) {
        final nom = snap.data?.nom ?? '';
        final prenom = nom.isEmpty ? '' : nom.split(' ').first;
        final lettre = nom.isEmpty ? 'S' : nom[0].toUpperCase();
        final canPost =
            !_loading && (_ctrl.text.trim().isNotEmpty || _imageBytes != null);

        return HomeCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Choix du type de publication
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final t in kTypesPost)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(iconeTypePost(t),
                              size: 16,
                              color: _type == t
                                  ? HomeColors.brand
                                  : HomeColors.mute),
                          label: Text(libelleTypePost(t)),
                          selected: _type == t,
                          onSelected: (_) => setState(() => _type = t),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(letter: lettre, color: HomeColors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: _indice(prenom),
                        hintStyle: const TextStyle(color: HomeColors.mute),
                        filled: true,
                        fillColor: HomeColors.input,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Thème, seulement pour astuce / note / question
              if (_type != 'publication') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _categorie,
                  decoration: InputDecoration(
                    labelText: 'Thème',
                    isDense: true,
                    filled: true,
                    fillColor: HomeColors.input,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    for (final t in kThemes)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) =>
                      setState(() => _categorie = v ?? _categorie),
                ),
              ],
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() => _imageBytes = null),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      children: [
                        _Tool(
                            icon: Icons.image_outlined,
                            label: 'Photo',
                            onTap: _pickImage),
                        _Tool(
                            icon: Icons.emoji_emotions_outlined,
                            label: 'Humeur',
                            onTap: _pickMood),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: canPost ? () => _publier(nom) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeColors.brand,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Publier',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tool({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: HomeColors.brand,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}