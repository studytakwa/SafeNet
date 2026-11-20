import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Home/widgets/home_common.dart';
import 'admin_widgets.dart';

class AdminReclamationsPage extends StatelessWidget {
  const AdminReclamationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('reclamations').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text('Aucune réclamation pour le moment. 👍', style: TextStyle(color: HomeColors.mute)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>? ?? {};
            final motif = data['motif'] ?? 'Sans motif';
            final cibleType = data['cibleType'] ?? 'post';
            final cibleId = data['cibleId'] ?? '';
            final auteurUid = data['auteurUid'] ?? '';
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

            return HomeCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cibleType == 'profil' ? 'Signalement Profil' : 'Signalement Publication',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            dateComplete(createdAt),
                            style: const TextStyle(fontSize: 12, color: HomeColors.mute),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Motif : $motif',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text('Cible ID : $cibleId', style: const TextStyle(fontSize: 12, color: HomeColors.mute)),
                    Text('Auteur UID : $auteurUid', style: const TextStyle(fontSize: 12, color: HomeColors.mute)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () async {
                            await db.collection('reclamations').doc(doc.id).delete();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Réclamation traitée et supprimée.')),
                            );
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Traiter / Supprimer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
