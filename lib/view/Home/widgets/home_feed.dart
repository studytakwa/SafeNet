import 'package:flutter/material.dart';
import '../../../controllers/social_controller.dart';
import '../../../models/post_model.dart';
import 'home_common.dart';
import 'post_list.dart';

/// Fil d'actualité avec deux onglets : Tous / Amis (activité des amis),
/// et un filtre par type de publication.
class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final _s = SocialController();
  late final Stream<List<String>> _amis = _s.idsAmis();
  bool _soloAmis = false;
  String? _type; // null = tous les types

  static const _filtres = ['astuce', 'note', 'question'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: false, label: Text('Tous')),
              ButtonSegment(value: true, label: Text('Amis')),
            ],
            selected: {_soloAmis},
            onSelectionChanged: (v) => setState(() => _soloAmis = v.first),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Tout'),
                  selected: _type == null,
                  onSelected: (_) => setState(() => _type = null),
                ),
              ),
              for (final t in _filtres)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(iconeTypePost(t),
                        size: 16,
                        color:
                        _type == t ? HomeColors.brand : HomeColors.mute),
                    label: Text(libelleTypePost(t)),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!_soloAmis)
          PostsList(key: ValueKey('tous-$_type'), type: _type)
        else
          StreamBuilder<List<String>>(
            stream: _amis,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final ids = snap.data!;
              if (ids.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "Ajoutez des amis pour suivre leur activité ici.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HomeColors.mute),
                  ),
                );
              }
              return PostsList(
                key: ValueKey('amis-$_type'),
                authorIds: [...ids, _s.uid],
                type: _type,
              );
            },
          ),
      ],
    );
  }
}