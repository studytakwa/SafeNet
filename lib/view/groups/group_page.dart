import 'package:flutter/material.dart';
import '../../controllers/group_controller.dart';
import '../../models/groupe_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import 'group_chat_page.dart';

/// Liste des groupes thématiques : Découvrir / Mes groupes + filtre par thème.
class GroupesPage extends StatefulWidget {
  const GroupesPage({super.key});

  @override
  State<GroupesPage> createState() => _GroupesPageState();
}

class _GroupesPageState extends State<GroupesPage> {
  final _ctrl = GroupController();
  late final Stream<List<GroupModel>> _stream = _ctrl.tousLesGroupes();
  String? _theme; // null = tous les thèmes
  final Set<String> _demandesLocales = {};

  void _ouvrir(String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupeChatPage(groupId: groupId)),
    );
  }

  Future<void> _demanderRejoindre(GroupModel g) async {
    setState(() {
      _demandesLocales.add(g.id);
    });

    final res = await _ctrl.demanderRejoindre(g);
    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      if (!g.isPending(_ctrl.uid)) {
        setState(() {
          _demandesLocales.remove(g.id);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _annulerDemande(String groupId) async {
    setState(() {
      _demandesLocales.remove(groupId);
    });
    await _ctrl.annulerDemande(groupId);
  }

  Future<void> _creer() async {
    final id = await showDialog<String>(
      context: context,
      builder: (_) => const _CreerGroupeDialog(),
    );
    if (id != null && mounted) _ouvrir(id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: HomeColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primaryDark),
          title: const Text(
            'Groupes',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: Colors.black45,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [Tab(text: 'Découvrir'), Tab(text: 'Mes groupes')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 2,
          onPressed: _creer,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Créer un groupe',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Tous'),
                      selected: _theme == null,
                      selectedColor: AppColors.mintContainer,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _theme == null
                            ? AppColors.primaryDark
                            : Colors.black87,
                      ),
                      onSelected: (_) => setState(() => _theme = null),
                    ),
                  ),
                  for (final t in kThemes)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(iconeTheme(t),
                            size: 16,
                            color: _theme == t
                                ? AppColors.primaryDark
                                : AppColors.primary),
                        label: Text(t),
                        selected: _theme == t,
                        selectedColor: AppColors.mintContainer,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _theme == t
                              ? AppColors.primaryDark
                              : Colors.black87,
                        ),
                        onSelected: (_) => setState(() => _theme = t),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<GroupModel>>(
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
                  final tous = snap.data!
                      .where((g) => _theme == null || g.theme == _theme)
                      .toList();
                  final miens =
                      tous.where((g) => g.isMember(_ctrl.uid)).toList();
                  final autres =
                      tous.where((g) => !g.isMember(_ctrl.uid)).toList();
                  return TabBarView(
                    children: [
                      _Liste(
                        groupes: autres,
                        vide:
                            'Aucun groupe à découvrir.\nCréez le premier !',
                        onTap: _ouvrir,
                        ctrl: _ctrl,
                        demandesLocales: _demandesLocales,
                        onDemanderRejoindre: _demanderRejoindre,
                        onAnnulerDemande: _annulerDemande,
                      ),
                      _Liste(
                        groupes: miens,
                        vide: "Vous n'avez rejoint aucun groupe.",
                        onTap: _ouvrir,
                        ctrl: _ctrl,
                        demandesLocales: _demandesLocales,
                        onDemanderRejoindre: _demanderRejoindre,
                        onAnnulerDemande: _annulerDemande,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Liste extends StatelessWidget {
  final List<GroupModel> groupes;
  final String vide;
  final void Function(String id) onTap;
  final GroupController ctrl;
  final Set<String> demandesLocales;
  final void Function(GroupModel g) onDemanderRejoindre;
  final void Function(String id) onAnnulerDemande;

  const _Liste({
    required this.groupes,
    required this.vide,
    required this.onTap,
    required this.ctrl,
    required this.demandesLocales,
    required this.onDemanderRejoindre,
    required this.onAnnulerDemande,
  });

  @override
  Widget build(BuildContext context) {
    if (groupes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(vide,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HomeColors.mute, height: 1.4)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      itemCount: groupes.length,
      itemBuilder: (_, i) {
        final g = groupes[i];
        final estCreateur = g.creatorId == ctrl.uid ||
            (g.creatorId.isEmpty &&
                g.members.isNotEmpty &&
                g.members.first == ctrl.uid);
        final estMembre = g.isMember(ctrl.uid);
        final estEnAttente =
            g.isPending(ctrl.uid) || demandesLocales.contains(g.id);

        Widget actionButton;
        if (estCreateur && g.pendingRequests.isNotEmpty) {
          actionButton = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_rounded,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  '${g.pendingRequests.length}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        } else if (estMembre) {
          actionButton = const Icon(Icons.chevron_right, color: AppColors.primaryDark);
        } else if (estEnAttente) {
          actionButton = OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => onAnnulerDemande(g.id),
            child: const Text('En attente'),
          );
        } else {
          actionButton = FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => onDemanderRejoindre(g),
            child: const Text('Rejoindre'),
          );
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HomeColors.line),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            onTap: () => onTap(g.id),
            leading: CircleAvatar(
              backgroundColor: AppColors.mintContainer,
              child: Icon(iconeTheme(g.theme), color: AppColors.primaryDark),
            ),
            title: Text(g.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark)),
            subtitle: Text(
              '${g.theme} · ${g.members.length} membre${g.members.length > 1 ? 's' : ''}'
              '${estCreateur && g.pendingRequests.isNotEmpty ? ' · ${g.pendingRequests.length} demande${g.pendingRequests.length > 1 ? 's' : ''} en attente' : ''}'
              '${g.description.isEmpty ? '' : '\n${g.description}'}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            isThreeLine: g.description.isNotEmpty,
            trailing: actionButton,
          ),
        );
      },
    );
  }
}

class _CreerGroupeDialog extends StatefulWidget {
  const _CreerGroupeDialog();

  @override
  State<_CreerGroupeDialog> createState() => _CreerGroupeDialogState();
}

class _CreerGroupeDialogState extends State<_CreerGroupeDialog> {
  final _nom = TextEditingController();
  final _desc = TextEditingController();
  final _ctrl = GroupController();
  String _theme = kThemes.first;
  bool _loading = false;

  @override
  void dispose() {
    _nom.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final nom = _nom.text.trim();
    if (nom.isEmpty) return;
    setState(() => _loading = true);
    try {
      final id = await _ctrl.creer(
        name: nom,
        theme: _theme,
        description: _desc.text.trim(),
      );
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Création impossible : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un groupe',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nom,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Nom du groupe'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _theme,
              decoration: const InputDecoration(labelText: 'Thème'),
              items: [
                for (final t in kThemes)
                  DropdownMenuItem(
                    value: t,
                    child: Row(children: [
                      Icon(iconeTheme(t), size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(t),
                    ]),
                  ),
              ],
              onChanged: (v) => setState(() => _theme = v ?? _theme),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _desc,
              maxLength: 150,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _loading ? null : _valider,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Créer'),
        ),
      ],
    );
  }
}
