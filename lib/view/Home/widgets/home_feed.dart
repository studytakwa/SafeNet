import 'package:flutter/material.dart';
import '../../../controllers/social_controller.dart';
import 'home_common.dart';
import 'post_list.dart';

/// Fil d'actualité avec deux onglets : Tous / Amis (activité des amis).
class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final _s = SocialController();
  late final Stream<List<String>> _amis = _s.idsAmis();
  bool _soloAmis = false;

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
        const SizedBox(height: 16),
        if (!_soloAmis)
          const PostsList()
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
              return PostsList(authorIds: [...ids, _s.uid]);
            },
          ),
      ],
    );
  }
}