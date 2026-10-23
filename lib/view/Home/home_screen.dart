import 'package:flutter/material.dart';
import 'package:safenet/view/Home/widgets/profile_search_bar.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profil_controller.dart';
import '../../models/profil_model.dart';
import '../profil/profil_page.dart';
import 'widgets/home_common.dart';
import 'widgets/post_composer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showSearch = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const _Logo(),
            if (showSearch) ...[
              const SizedBox(width: 24),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: const _SearchField(),
                  ),
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
        actions: [
          if (!showSearch)
            IconButton(
              onPressed: () {},
              tooltip: 'Rechercher',
              icon: const Icon(Icons.search),
            ),
          const _RoundIcon(icon: Icons.chat_bubble_outline, tooltip: 'Messages'),
          const _RoundIcon(
              icon: Icons.notifications_none, tooltip: 'Notifications'),
          const _AvatarMenu(),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: HomeColors.line),
        ),
      ),
      // Corps : zone de publication sous l'en-tête
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 24),
            child: Column(
              children: [
                ProfileSearchBar(),
                PostComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: HomeColors.brand,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/logo.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'SafeNet',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: HomeColors.brand,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher des personnes, des groupes…',
        hintStyle: const TextStyle(color: HomeColors.mute, fontSize: 14),
        prefixIcon: const Icon(Icons.search, size: 20, color: HomeColors.mute),
        filled: true,
        fillColor: HomeColors.input,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: HomeColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: HomeColors.line),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _RoundIcon({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: HomeColors.soft,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: () {},
          tooltip: tooltip,
          icon: Icon(icon, color: HomeColors.brand, size: 20),
        ),
      ),
    );
  }
}

/// Avatar en haut à droite : ouvre "Mon profil" ou "Se déconnecter".
class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu();

  @override
  Widget build(BuildContext context) {
    final profilController = ProfilController();
    final uid = profilController.uidCourant;

    return StreamBuilder<ProfilModel>(
      stream: uid.isNotEmpty ? profilController.suivreProfil(uid) : null,
      builder: (context, snapshot) {
        final profil = snapshot.data;
        final lettre = (profil != null && profil.nom.isNotEmpty)
            ? profil.nom[0].toUpperCase()
            : 'S';

        return PopupMenuButton<String>(
          tooltip: 'Mon compte',
          offset: const Offset(0, 48),
          onSelected: (value) {
            if (value == 'profil') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilPage()),
              );
            } else if (value == 'logout') {
              AuthController().seDeconnecter();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'profil', child: Text('Mon profil')),
            PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Avatar(letter: lettre, color: HomeColors.purple),
          ),
        );
      },
    );
  }
}
