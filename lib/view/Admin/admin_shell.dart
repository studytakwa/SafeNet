import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';
import '../Home/widgets/home_common.dart';
import '../authentification/auth_wrapper.dart';
import 'admin_dashboard_page.dart';
import 'admin_post_page.dart';
import 'admin_user_page.dart';

/// Structure de l'espace admin : navigation (barre latérale sur grand écran,
/// barre du bas sur mobile) + vérification du rôle administrateur.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _c = AdminController();
  late final Stream<bool> _role = _c.roleAdmin();
  int _index = 0;
  int _postsTab = 0;

  Future<void> _quitter() async {
    await _c.deconnecter();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (route) => false,
    );
  }

  Future<void> _confirmerDeconnexion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Se déconnecter ?',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
            'Voulez-vous vraiment quitter l\'espace administrateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (ok == true) await _quitter();
  }

  Widget _page() {
    switch (_index) {
      case 1:
        return const AdminUsersPage();
      case 2:
        return AdminPostsPage(
            key: ValueKey('posts$_postsTab'), initialTab: _postsTab);
      default:
        return AdminDashboardPage(
          onOpenUsers: () => setState(() => _index = 1),
          onOpenPosts: (tab) => setState(() {
            _postsTab = tab;
            _index = 2;
          }),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _role,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data != true) {
          return Scaffold(
            backgroundColor: HomeColors.bg,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 56, color: Color(0xFFD64545)),
                    const SizedBox(height: 16),
                    const Text('Accès refusé',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Cet espace est réservé à l\'administrateur.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: HomeColors.brand),
                      onPressed: _quitter,
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        const destinations = [
          (Icons.dashboard_outlined, Icons.dashboard, 'Tableau de bord'),
          (Icons.people_outline, Icons.people, 'Utilisateurs'),
          (Icons.fact_check_outlined, Icons.fact_check, 'Publications'),
        ];

        return LayoutBuilder(
          builder: (context, cs) {
            final large = cs.maxWidth >= 800;
            final contenu = Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _page(),
              ),
            );
            return Scaffold(
              backgroundColor: HomeColors.bg,
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: HomeColors.brand),
                title: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: HomeColors.brand),
                    SizedBox(width: 8),
                    Text('SafeNet Admin',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: HomeColors.brand)),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Se déconnecter',
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 24),
                    onPressed: _confirmerDeconnexion,
                  ),
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, color: HomeColors.line),
                ),
              ),
              body: large
                  ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (i) =>
                        setState(() => _index = i),
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(
                          icon: Icon(d.$1),
                          selectedIcon: Icon(d.$2),
                          label: Text(d.$3),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: contenu),
                ],
              )
                  : contenu,
              bottomNavigationBar: large
                  ? null
                  : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: d.$3,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}