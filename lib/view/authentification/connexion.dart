import 'package:flutter/material.dart';
import '../../controllers/connexion_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/Auth layout.dart';
import 'inscription.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _EtatConnexion();
}

class _EtatConnexion extends State<ConnexionPage> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  final _ctrlMotDePasse = TextEditingController();
  final _controller = ConnexionController();

  bool _chargement = false;
  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlMotDePasse.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texte),
      backgroundColor: AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  Future<void> _seConnecter() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() => _chargement = true);

    final erreur = await _controller.connecter(
      email: _ctrlEmail.text,
      motDePasse: _ctrlMotDePasse.text,
    );

    if (!mounted) return;
    setState(() => _chargement = false);

    if (erreur == null) {
      _message('Connexion réussie');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _message(erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      afficherRetour: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EnteteMarque(tailleLogo: 60),
          const SizedBox(height: 24),
          CarteAuth(
            child: Form(
              key: _cleFormulaire,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Veuillez entrer vos identifiants ci-dessous.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _ctrlEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: champDecoration(
                      label: 'Email',
                      icone: Icons.email_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Entrez votre email';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v.trim())) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ctrlMotDePasse,
                    obscureText: _masquerMotDePasse,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _seConnecter(),
                    decoration: champDecoration(
                      label: 'Mot de passe',
                      icone: Icons.lock_outline,
                      suffixe: IconButton(
                        icon: Icon(
                          _masquerMotDePasse
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () => setState(
                                () => _masquerMotDePasse = !_masquerMotDePasse),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Entrez votre mot de passe'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: styleBoutonPrincipal(),
                    onPressed: _chargement ? null : _seConnecter,
                    child: _chargement
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Se connecter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Pas encore de compte ?',
                style: TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Inscription()),
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
