import 'package:flutter/material.dart';
import '../../controllers/contenu_controller.dart';
import '../../models/contenu_model.dart';
import '../../models/groupe_model.dart';
import '../../theme/app_theme.dart';
import '../../theme/auth_layout.dart'; // champDecoration, styleBoutonPrincipal
import '../Home/widgets/home_common.dart';

class AjouterContenuPage extends StatefulWidget {
  const AjouterContenuPage({super.key});

  @override
  State<AjouterContenuPage> createState() => _AjouterContenuPageState();
}

class _AjouterContenuPageState extends State<AjouterContenuPage> {
  final _ctrl = ContenuController();
  final _cle = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _description = TextEditingController();
  final _lien = TextEditingController();
  String _type = kTypesContenu.first;
  String _categorie = kThemes.first;
  bool _loading = false;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _lien.dispose();
    super.dispose();
  }

  Future<void> _publier() async {
    if (!_cle.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _ctrl.partager(
        titre: _titre.text.trim(),
        description: _description.text.trim(),
        type: _type,
        categorie: _categorie,
        lien: _lien.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contenu partagé avec la communauté !')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Partage impossible : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text('Partager un contenu',
            style: TextStyle(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _cle,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: champDecoration(
                      label: 'Type de contenu', icone: Icons.category_outlined),
                  items: [
                    for (final t in kTypesContenu)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _categorie,
                  decoration: champDecoration(
                      label: 'Thème', icone: Icons.label_outline),
                  items: [
                    for (final t in kThemes)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) => setState(() => _categorie = v ?? _categorie),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titre,
                  maxLength: 80,
                  decoration:
                  champDecoration(label: 'Titre', icone: Icons.title),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Au moins 3 caractères'
                      : null,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _description,
                  maxLength: 2000,
                  maxLines: 8,
                  minLines: 5,
                  decoration: champDecoration(
                      label: 'Contenu (cours, astuce, explication…)',
                      icone: Icons.notes),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Au moins 10 caractères'
                      : null,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _lien,
                  keyboardType: TextInputType.url,
                  decoration: champDecoration(
                      label: 'Lien (optionnel)', icone: Icons.link),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return null;
                    return t.startsWith('http://') || t.startsWith('https://')
                        ? null
                        : 'Le lien doit commencer par http:// ou https://';
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: styleBoutonPrincipal(),
                  onPressed: _loading ? null : _publier,
                  child: _loading
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Partager'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}