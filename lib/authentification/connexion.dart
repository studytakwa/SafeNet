import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _EtatConnexion();
}

class _EtatConnexion extends State<ConnexionPage> {
  static const Color _couleurPrincipale = Color(0xFF6C4FD8);

  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  final _ctrlMotDePasse = TextEditingController();
  bool _chargement = false;
  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlMotDePasse.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() => _chargement = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _ctrlEmail.text.trim(),
        password: _ctrlMotDePasse.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie')),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email ou mot de passe incorrect.';
          break;
        case 'invalid-email':
          message = 'Adresse email invalide.';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé.';
          break;
        case 'network-request-failed':
          message = 'Pas de connexion internet.';
          break;
        default:
          message = 'Erreur de connexion. Réessayez.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  InputDecoration _decoration(String label, IconData icone, {Widget? suffixe}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icone, color: _couleurPrincipale),
      suffixIcon: suffixe,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _couleurPrincipale, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE7FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _cleFormulaire,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _couleurPrincipale.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 48,
                        color: _couleurPrincipale,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Bon retour !',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2250),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour accéder à votre compte SafeNet.',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _ctrlEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration('Email', Icons.email_outlined),
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
                    decoration: _decoration(
                      'Mot de passe',
                      Icons.lock_outline,
                      suffixe: IconButton(
                        icon: Icon(_masquerMotDePasse
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                                () => _masquerMotDePasse = !_masquerMotDePasse),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Entrez votre mot de passe'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _chargement ? null : _seConnecter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _couleurPrincipale,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _chargement
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}