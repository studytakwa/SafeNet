import 'package:flutter/material.dart';
import '../../controllers/contenu_controller.dart';
import '../../models/contenu_model.dart';
import '../../models/groupe_model.dart'; // kThemes, iconeTheme
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import 'ajouter_contenu_page.dart';
import 'contenu_detail_page.dart';

IconData iconeType(String type) {
  switch (type) {
    case 'Note de cours':
      return Icons.menu_book_outlined;
    case 'Ressource':
      return Icons.link_rounded;
    default:
      return Icons.lightbulb_outline_rounded;
  }
}

class ContenusPage extends StatefulWidget {
  const ContenusPage({super.key});

  @override
  State<ContenusPage> createState() => _ContenusPageState();
}

class _ContenusPageState extends State<ContenusPage> {
  final _ctrl = ContenuController();
  late final Stream<List<Contenu>> _stream = _ctrl.tous();
  String? _type; // null = tous les types
  String? _theme; // null = tous les thèmes
  String _recherche = '';

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icone == null
            ? null
            : Icon(icone,
            size: 16,
            color: selected ? AppColors.primaryDark : AppColors.primary),
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.mintContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? AppColors.primaryDark : Colors.black87,
        ),
        onSelected: (_) => onTap(),
      ),
    );
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
        title: const Text(
          'Contenus éducatifs',
          style: TextStyle(
              color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AjouterContenuPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Partager',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: (v) => setState(() => _recherche = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher un cours, une astuce…',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: HomeColors.input,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: HomeColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: HomeColors.line),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _chip(
                    label: 'Tous les types',
                    selected: _type == null,
                    onTap: () => setState(() => _type = null)),
                for (final t in kTypesContenu)
                  _chip(
                      label: t,
                      icone: iconeType(t),
                      selected: _type == t,
                      onTap: () => setState(() => _type = t)),
              ],
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _chip(
                    label: 'Tous les thèmes',
                    selected: _theme == null,
                    onTap: () => setState(() => _theme = null)),
                for (final t in kThemes)
                  _chip(
                      label: t,
                      icone: iconeTheme(t),
                      selected: _theme == t,
                      onTap: () => setState(() => _theme = t)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Contenu>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text('Erreur : ${snap.error}',
                        style: const TextStyle(color: Colors.redAccent)),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final liste = snap.data!.where((c) {
                  if (_type != null && c.type != _type) return false;
                  if (_theme != null && c.categorie != _theme) return false;
                  if (_recherche.isNotEmpty &&
                      !c.titre.toLowerCase().contains(_recherche) &&
                      !c.description.toLowerCase().contains(_recherche)) {
                    return false;
                  }
                  return true;
                }).toList();

                if (liste.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucun contenu pour le moment.\nSois le premier à partager !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HomeColors.mute, height: 1.4),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                  itemCount: liste.length,
                  itemBuilder: (_, i) => _CarteContenu(
                    contenu: liste[i],
                    uid: _ctrl.uid,
                    onUtile: () => _ctrl.basculerUtile(liste[i]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ContenuDetailPage(contenuId: liste[i].id)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteContenu extends StatelessWidget {
  final Contenu contenu;
  final String uid;
  final VoidCallback onUtile;
  final VoidCallback onTap;
  const _CarteContenu({
    required this.contenu,
    required this.uid,
    required this.onUtile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = contenu;
    final utile = c.estUtilePour(uid);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HomeColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mintContainer,
                  child: Icon(iconeType(c.type),
                      size: 18, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryDark)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(c.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, height: 1.3)),
              const SizedBox(height: 10),
              Row(children: [
                Icon(iconeTheme(c.categorie), size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('${c.type} · ${c.categorie}',
                    style: const TextStyle(
                        fontSize: 12, color: HomeColors.mute)),
                const Spacer(),
                Text('par ${c.auteurNom}',
                    style: const TextStyle(
                        fontSize: 12, color: HomeColors.mute)),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onUtile,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      Icon(
                        utile ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: utile ? AppColors.primaryDark : HomeColors.mute,
                      ),
                      const SizedBox(width: 4),
                      Text('${c.utiles.length}',
                          style: const TextStyle(fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}