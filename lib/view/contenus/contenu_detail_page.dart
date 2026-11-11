import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/contenu_controller.dart';
import '../../models/contenu_model.dart';
import '../../models/groupe_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';

class ContenuDetailPage extends StatelessWidget {
  final String contenuId;
  const ContenuDetailPage({super.key, required this.contenuId});

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final ctrl = ContenuController();
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text('Contenu',
            style: TextStyle(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('contenus')
            .doc(contenuId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return const Center(child: Text('Ce contenu a été supprimé.'));
          }
          final c = Contenu.fromDoc(snap.data!);
          final estAuteur = c.auteurId == ctrl.uid;
          final utile = c.estUtilePour(ctrl.uid);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(c.titre,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    Chip(
                      avatar: Icon(iconeTheme(c.categorie), size: 16),
                      label: Text(c.categorie),
                      backgroundColor: AppColors.mintContainer,
                    ),
                    Chip(label: Text(c.type)),
                  ]),
                  Text('Par ${c.auteurNom} · ${_date(c.date)}',
                      style: const TextStyle(color: HomeColors.mute)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: HomeColors.line),
                    ),
                    child: SelectableText(c.description,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                  ),
                  if (c.lien.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HomeColors.line),
                      ),
                      child: Row(children: [
                        const Icon(Icons.link, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(c.lien,
                              style: const TextStyle(
                                  color: AppColors.primaryDark)),
                        ),
                        IconButton(
                          tooltip: 'Copier le lien',
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: c.lien));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lien copié')),
                            );
                          },
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                        utile ? AppColors.primaryDark : Colors.white,
                        foregroundColor:
                        utile ? Colors.white : AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => ctrl.basculerUtile(c),
                      icon: Icon(
                          utile ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 18),
                      label: Text('Utile · ${c.utiles.length}'),
                    ),
                    const Spacer(),
                    if (estAuteur)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Supprimer ce contenu ?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Supprimer')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await ctrl.supprimer(c.id);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Supprimer'),
                      ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}