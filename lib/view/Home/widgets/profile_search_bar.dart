import 'package:flutter/material.dart';

import '../../../controllers/profil_controller.dart';
import '../../../models/profil_model.dart';
import '../../profil/profil_page.dart';
import 'home_common.dart';
class ProfileSearchBar extends StatefulWidget {
  const ProfileSearchBar({super.key});

  @override
  State<ProfileSearchBar> createState() => _ProfileSearchBarState();
}

class _ProfileSearchBarState extends State<ProfileSearchBar> {
  final _controller = ProfilController();
  final _ctrl = TextEditingController();

  List<ProfilModel> _profils = [];
  bool _chargement = true;
  bool _erreur = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = false;
    });
    try {
      final liste = await _controller.chargerProfils();
      if (!mounted) return;
      setState(() {
        _profils = liste;
        _chargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erreur = true;
        _chargement = false;
      });
    }
  }

  /// Minuscules et sans accents, pour que "hedi" trouve "Hédi".
  String _norm(String s) {
    const from = 'àâäéèêëîïôöùûüç';
    const to = 'aaaeeeeiioouuuc';
    var out = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  List<ProfilModel> get _resultats {
    final q = _norm(_query.trim());
    if (q.isEmpty) return [];
    return _profils
        .where((p) =>
    p.uid != _controller.uidCourant && _norm(p.nom).contains(q))
        .take(10)
        .toList();
  }

  void _ouvrir(ProfilModel profil) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilPage(uid: profil.uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recherche = _query.trim().isNotEmpty;
    final resultats = _resultats;

    return HomeCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (resultats.isNotEmpty) _ouvrir(resultats.first);
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un profil par nom…',
              hintStyle: const TextStyle(color: HomeColors.mute, fontSize: 14),
              prefixIcon:
              const Icon(Icons.search, size: 20, color: HomeColors.mute),
              suffixIcon: recherche
                  ? IconButton(
                tooltip: 'Effacer',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _ctrl.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
              filled: true,
              fillColor: HomeColors.input,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (recherche) ...[
            const SizedBox(height: 8),
            if (_chargement)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_erreur)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text('Impossible de charger les profils.',
                        style: TextStyle(color: HomeColors.mute)),
                    TextButton(
                      onPressed: _charger,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (resultats.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Aucun profil trouvé pour « ${_query.trim()} ».',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: HomeColors.mute),
                  ),
                )
              else
                for (final p in resultats) _Resultat(profil: p, onTap: () => _ouvrir(p)),
          ],
        ],
      ),
    );
  }
}

class _Resultat extends StatelessWidget {
  final ProfilModel profil;
  final VoidCallback onTap;
  const _Resultat({required this.profil, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photo = profil.photoOctets;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: HomeColors.blue,
        backgroundImage: photo != null ? MemoryImage(photo) : null,
        child: photo == null
            ? Text(
          profil.nom.trim()[0].toUpperCase(),
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: HomeColors.ink),
        )
            : null,
      ),
      title: Text(profil.nom,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: HomeColors.ink)),
      subtitle: profil.bio.isNotEmpty
          ? Text(profil.bio,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: HomeColors.mute))
          : null,
      trailing: const Icon(Icons.chevron_right, color: HomeColors.mute),
    );
  }
}