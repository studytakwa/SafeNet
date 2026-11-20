import 'package:flutter/material.dart';
import '../../services/reclamation_service.dart';

Future<void> showReportDialog(BuildContext context, {required String cibleId, required String cibleType}) async {
  final motifCtrl = TextEditingController();
  String motifSelectionne = 'Risque pour les adolescents';

  final motifs = [
    'Risque pour les adolescents',
    'Contenu inapproprié ou violent',
    'Harcèlement ou intimidation',
    'Fausse information',
    'Autre',
  ];

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        title: const Text('Signaler / Réclamation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionnez ou décrivez le motif du signalement :',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            for (final m in motifs)
              RadioListTile<String>(
                title: Text(m, style: const TextStyle(fontSize: 14)),
                value: m,
                groupValue: motifSelectionne,
                onChanged: (v) => setStateModal(() => motifSelectionne = v!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            if (motifSelectionne == 'Autre') ...[
              const SizedBox(height: 8),
              TextField(
                controller: motifCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Précisez le motif...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    ),
  );

  final detail = motifSelectionne == 'Autre' ? motifCtrl.text.trim() : motifSelectionne;
  motifCtrl.dispose();

  if (ok != true || detail.isEmpty) return;

  try {
    await ReclamationService().envoyerReclamation(
      cibleId: cibleId,
      cibleType: cibleType,
      motif: detail,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signalement envoyé à l\'administrateur avec succès.')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}
