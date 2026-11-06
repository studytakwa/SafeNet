import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/group_controller.dart';
import '../../models/groupe_model.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../social/user_builder.dart';

/// Discussion d'un groupe avec support d'envoi de messages, fichiers (PDF/Cours),
/// gestion des membres et approbation des demandes d'adhésion par le créateur.
class GroupeChatPage extends StatefulWidget {
  final String groupId;
  const GroupeChatPage({super.key, required this.groupId});

  @override
  State<GroupeChatPage> createState() => _GroupeChatPageState();
}

class _GroupeChatPageState extends State<GroupeChatPage> {
  final _ctrl = GroupController();
  final _tc = TextEditingController();
  final _picker = ImagePicker();
  final Set<String> _demandesLocales = {};

  late final Stream<GroupModel?> _groupe = _ctrl.groupe(widget.groupId);
  late final Stream<List<GroupMessage>> _messages =
      _ctrl.messages(widget.groupId);

  Uint8List? _fichierOctets;
  String? _nomFichier;
  String? _typeFichier;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _joindreFichier() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ajouter un document / cours',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent),
              ),
              title: const Text('Cours / Document PDF'),
              subtitle: const Text('Sélectionner un fichier de cours'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickMedia();
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  setState(() {
                    _fichierOctets = bytes;
                    _nomFichier = file.name;
                    _typeFichier = 'pdf';
                  });
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image_rounded, color: AppColors.primary),
              ),
              title: const Text('Image / Schéma'),
              subtitle: const Text('Sélectionner une photo ou illustration'),
              onTap: () async {
                Navigator.pop(context);
                final file =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  setState(() {
                    _fichierOctets = bytes;
                    _nomFichier = file.name;
                    _typeFichier = 'image';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final t = _tc.text.trim();
    if (t.isEmpty && _fichierOctets == null) return;

    final bytes = _fichierOctets;
    final name = _nomFichier;
    final type = _typeFichier;

    _tc.clear();
    setState(() {
      _fichierOctets = null;
      _nomFichier = null;
      _typeFichier = null;
    });

    try {
      await _ctrl.envoyer(
        widget.groupId,
        t,
        fileName: name,
        fileBytes: bytes,
        fileType: type,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message non envoyé : $e')),
        );
      }
    }
  }

  Future<bool> _confirmer(String titre, String bouton) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titre),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: Text(bouton)),
        ],
      ),
    );
    return ok == true;
  }

  void _afficherMembres(GroupModel initialGroup, bool createur) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StreamBuilder<GroupModel?>(
        stream: _ctrl.groupe(initialGroup.id),
        builder: (context, snap) {
          final g = snap.data ?? initialGroup;
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_rounded, color: AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Text(
                      'Membres du groupe (${g.members.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: g.members.length,
                    itemBuilder: (_, i) {
                      final memberUid = g.members[i];
                      final estCreateurMembre = memberUid == g.creatorId;
                      final estMoi = memberUid == _ctrl.uid;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                        leading: UserAvatar(uid: memberUid),
                        title: Row(
                          children: [
                            Flexible(child: UserName(uid: memberUid)),
                            if (estCreateurMembre) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.mintContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Créateur',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark)),
                              ),
                            ],
                          ],
                        ),
                        trailing: (createur && !estMoi && !estCreateurMembre)
                            ? OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                                onPressed: () async {
                                  if (await _confirmer(
                                      'Retirer ce membre du groupe ?', 'Retirer')) {
                                    await _ctrl.retirerMembre(g.id, memberUid);
                                  }
                                },
                                icon: const Icon(Icons.person_remove_rounded,
                                    size: 16),
                                label: const Text('Retirer'),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _afficherDemandes(GroupModel initialGroup) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StreamBuilder<GroupModel?>(
        stream: _ctrl.groupe(initialGroup.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final g = snap.data ?? initialGroup;
          final pending = g.pendingRequests;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_add_rounded,
                        color: AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demandes d\'adhésion (${pending.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (pending.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('Aucune demande en attente.',
                          style: TextStyle(color: HomeColors.mute)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pending.length,
                      itemBuilder: (_, i) {
                        final applicantUid = pending[i];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 2),
                          leading: UserAvatar(uid: applicantUid),
                          title: UserName(uid: applicantUid),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                                onPressed: () async {
                                  await _ctrl.accepterDemande(g, applicantUid);
                                },
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Accepter'),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                                onPressed: () async {
                                  await _ctrl.refuserDemande(g.id, applicantUid);
                                },
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('Refuser'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _heure(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GroupModel?>(
      stream: _groupe,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final g = snap.data;
        if (g == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Ce groupe n'existe plus.")),
          );
        }
        final membre = g.isMember(_ctrl.uid);
        final createur = g.creatorId == _ctrl.uid ||
            (g.creatorId.isEmpty &&
                g.members.isNotEmpty &&
                g.members.first == _ctrl.uid);

        return Scaffold(
          backgroundColor: HomeColors.bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primaryDark),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mintContainer,
                  child: Icon(iconeTheme(g.theme),
                      size: 18, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '${g.theme} · ${g.members.length} membre${g.members.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 12, color: HomeColors.mute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.people_outline_rounded,
                    color: AppColors.primaryDark),
                tooltip: 'Membres',
                onPressed: () => _afficherMembres(g, createur),
              ),
              if (createur && g.pendingRequests.isNotEmpty)
                IconButton(
                  icon: Badge(
                    label: Text('${g.pendingRequests.length}'),
                    child: const Icon(Icons.person_add_rounded,
                        color: AppColors.primaryDark),
                  ),
                  tooltip: 'Demandes en attente',
                  onPressed: () => _afficherDemandes(g),
                ),
              if (membre)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.primaryDark),
                  onSelected: (v) async {
                    if (v == 'membres') {
                      _afficherMembres(g, createur);
                    } else if (v == 'demandes') {
                      _afficherDemandes(g);
                    } else if (v == 'quit' &&
                        await _confirmer('Quitter ce groupe ?', 'Quitter')) {
                      await _ctrl.quitter(g.id);
                      if (context.mounted) Navigator.pop(context);
                    } else if (v == 'delete' &&
                        await _confirmer(
                            'Supprimer ce groupe ?', 'Supprimer')) {
                      await _ctrl.supprimer(g.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'membres', child: Text('Membres du groupe')),
                    if (createur)
                      PopupMenuItem(
                          value: 'demandes',
                          child: Text(
                              'Demandes${g.pendingRequests.isNotEmpty ? ' (${g.pendingRequests.length})' : ''}')),
                    if (createur)
                      const PopupMenuItem(
                          value: 'delete', child: Text('Supprimer le groupe'))
                    else
                      const PopupMenuItem(
                          value: 'quit', child: Text('Quitter le groupe')),
                  ],
                ),
            ],
          ),
          body: membre ? _chat(g, createur) : _fiche(g),
        );
      },
    );
  }

  /// Fiche affichée aux non-membres.
  Widget _fiche(GroupModel g) {
    final estEnAttente = g.isPending(_ctrl.uid) || _demandesLocales.contains(g.id);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.mintContainer,
              child: Icon(iconeTheme(g.theme),
                  size: 36, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 16),
            Text(
              g.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${g.theme} · ${g.members.length} membre${g.members.length > 1 ? 's' : ''}',
              style: const TextStyle(color: HomeColors.mute),
            ),
            if (g.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(g.description, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            estEnAttente
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      setState(() {
                        _demandesLocales.remove(g.id);
                      });
                      _ctrl.annulerDemande(g.id);
                    },
                    icon: const Icon(Icons.hourglass_top_rounded),
                    label: const Text('Demande envoyée · Annuler'),
                  )
                : FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      setState(() {
                        _demandesLocales.add(g.id);
                      });
                      final res = await _ctrl.demanderRejoindre(g);
                      if (!mounted) return;
                      if (res.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(res.message),
                              duration: const Duration(seconds: 2)),
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
                              backgroundColor: Colors.redAccent),
                        );
                      }
                    },
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('Demander à rejoindre'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _chat(GroupModel g, bool createur) {
    return Column(
      children: [
        if (createur && g.pendingRequests.isNotEmpty)
          Material(
            color: AppColors.mintContainer,
            child: InkWell(
              onTap: () => _afficherDemandes(g),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.person_add_rounded,
                        color: AppColors.primaryDark, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${g.pendingRequests.length} demande${g.pendingRequests.length > 1 ? 's' : ''} d\'adhésion en attente',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Text('Gérer',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: StreamBuilder<List<GroupMessage>>(
            stream: _messages,
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
              final msgs = snap.data!;
              if (msgs.isEmpty) {
                return const Center(
                  child: Text('Lancez la discussion dans le groupe 👋',
                      style: TextStyle(color: HomeColors.mute)),
                );
              }
              return ListView.builder(
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final mine = m.senderId == _ctrl.uid;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: (mine || createur)
                          ? () async {
                              if (await _confirmer(
                                  'Supprimer ce message ?', 'Supprimer')) {
                                await _ctrl.supprimerMessage(g.id, m.id);
                              }
                            }
                          : null,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.78),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.primaryDark : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(mine ? 18 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 18),
                          ),
                          border: mine ? null : Border.all(color: HomeColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!mine)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: UserName(
                                  uid: m.senderId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            if (m.fileName != null)
                              _FichierJoint(
                                fileName: m.fileName!,
                                fileType: m.fileType,
                                isMine: mine,
                              ),
                            if (m.text.isNotEmpty)
                              Text(
                                m.text,
                                style: TextStyle(
                                  color: mine ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _heure(m.createdAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      mine ? Colors.white70 : HomeColors.mute,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_fichierOctets != null)
          Container(
            color: AppColors.mintContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _nomFichier ?? 'Fichier sélectionné',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.primaryDark, size: 18),
                  onPressed: () => setState(() {
                    _fichierOctets = null;
                    _nomFichier = null;
                    _typeFichier = null;
                  }),
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: HomeColors.line)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _joindreFichier,
                  tooltip: 'Joindre un cours / PDF',
                  icon: const Icon(Icons.attach_file_rounded,
                      color: AppColors.primaryDark),
                ),
                Expanded(
                  child: TextField(
                    controller: _tc,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Écrire dans le groupe…',
                      filled: true,
                      fillColor: AppColors.background,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: HomeColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: HomeColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.primaryDark,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FichierJoint extends StatelessWidget {
  final String fileName;
  final String? fileType;
  final bool isMine;

  const _FichierJoint({
    required this.fileName,
    this.fileType,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final estPdf =
        (fileType == 'pdf') || fileName.toLowerCase().endsWith('.pdf');
    final icone =
        estPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded;
    final couleur = estPdf ? Colors.redAccent : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMine
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMine ? Colors.white30 : HomeColors.line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: couleur, size: 22),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isMine ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                Text(
                  estPdf ? 'Document PDF / Cours' : 'Fichier joint',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine ? Colors.white70 : HomeColors.mute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
