import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../../models/admin_models.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import 'admin_widgets.dart';

/// Tableau de bord : statistiques + accès rapide aux sections.
class AdminDashboardPage extends StatefulWidget {
  final VoidCallback onOpenUsers;
  final void Function(int tab) onOpenPosts;
  const AdminDashboardPage({
    super.key,
    required this.onOpenUsers,
    required this.onOpenPosts,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _c = AdminController();
  late Future<AdminStats> _stats = _c.statistiques();

  void _recharger() => setState(() => _stats = _c.statistiques());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _recharger();
        await _stats;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tableau de bord Admin',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Vue d\'ensemble et modération de SafeNet',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _recharger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<AdminStats>(
            future: _stats,
            builder: (context, snap) {
              if (snap.hasError) {
                return Column(
                  children: [
                    Text('Impossible de charger les statistiques :\n${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                        onPressed: _recharger, child: const Text('Réessayer')),
                  ],
                );
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final s = snap.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistiques clés',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HomeColors.ink)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, cs) {
                      final cols = cs.maxWidth >= 640 ? 4 : 2;
                      final w = (cs.maxWidth - 12 * (cols - 1)) / cols;
                      Widget carte(StatCard c) => SizedBox(width: w, child: c);
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          carte(StatCard(
                            icon: Icons.people_outline,
                            label: 'Utilisateurs',
                            value: s.utilisateurs,
                            color: HomeColors.teal,
                            onTap: widget.onOpenUsers,
                          )),
                          carte(StatCard(
                            icon: Icons.hourglass_top,
                            label: 'En attente',
                            value: s.enAttente,
                            color: couleurStatut('pending'),
                            onTap: () => widget.onOpenPosts(0),
                          )),
                          carte(StatCard(
                            icon: Icons.check_circle_outline,
                            label: 'Acceptées',
                            value: s.acceptees,
                            color: couleurStatut('approved'),
                            onTap: () => widget.onOpenPosts(1),
                          )),
                          carte(StatCard(
                            icon: Icons.cancel_outlined,
                            label: 'Refusées',
                            value: s.refusees,
                            color: couleurStatut('rejected'),
                            onTap: () => widget.onOpenPosts(2),
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Accès rapides',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HomeColors.ink)),
                  const SizedBox(height: 12),
                  _Raccourci(
                    icon: Icons.people_alt_outlined,
                    titre: 'Gestion des utilisateurs',
                    sousTitre: '${s.utilisateurs} utilisateur(s) inscrit(s)',
                    onTap: widget.onOpenUsers,
                  ),
                  _Raccourci(
                    icon: Icons.fact_check_outlined,
                    titre: 'Gestion des publications',
                    sousTitre: s.enAttente == 0
                        ? 'Aucune publication à valider'
                        : '${s.enAttente} publication(s) à valider',
                    onTap: () => widget.onOpenPosts(0),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Raccourci extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;
  const _Raccourci({
    required this.icon,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: HomeColors.soft,
          child: Icon(icon, color: HomeColors.brand),
        ),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(sousTitre),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}