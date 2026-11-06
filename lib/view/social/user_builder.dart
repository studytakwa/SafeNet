import 'package:flutter/material.dart';
import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
import '../../theme/app_theme.dart';

/// Construit un widget à partir du profil d'un utilisateur (nom, photo…).
class UserBuilder extends StatefulWidget {
  final String uid;
  final Widget Function(BuildContext, ProfilModel?) builder;
  const UserBuilder({super.key, required this.uid, required this.builder});

  @override
  State<UserBuilder> createState() => _UserBuilderState();
}

class _UserBuilderState extends State<UserBuilder> {
  late Stream<ProfilModel> _stream;

  @override
  void initState() {
    super.initState();
    _stream = ProfilController().suivreProfil(widget.uid);
  }

  @override
  void didUpdateWidget(covariant UserBuilder old) {
    super.didUpdateWidget(old);
    if (old.uid != widget.uid) {
      _stream = ProfilController().suivreProfil(widget.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfilModel>(
      stream: _stream,
      builder: (context, snap) => widget.builder(context, snap.data),
    );
  }
}

class UserName extends StatelessWidget {
  final String uid;
  final TextStyle? style;
  const UserName({super.key, required this.uid, this.style});

  @override
  Widget build(BuildContext context) {
    return UserBuilder(
      uid: uid,
      builder: (_, p) => Text(
        (p == null || p.nom.isEmpty) ? 'Utilisateur' : p.nom,
        style: style ?? const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String uid;
  final double radius;
  const UserAvatar({super.key, required this.uid, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return UserBuilder(
      uid: uid,
      builder: (_, p) {
        final photo = p?.photoOctets;
        final lettre =
        (p == null || p.nom.isEmpty) ? '?' : p.nom.trim()[0].toUpperCase();
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.accent,
          backgroundImage: photo != null ? MemoryImage(photo) : null,
          child: photo == null
              ? Text(
                  lettre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: radius * 0.8,
                  ),
                )
              : null,
        );
      },
    );
  }
}
