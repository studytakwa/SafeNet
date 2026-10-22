import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../profil/profil_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeNet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mon profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => authController.seDeconnecter(),
          ),
        ],
      ),
      body: Center(child: Text('Connecté : ${user?.email}')),
    );
  }
}
