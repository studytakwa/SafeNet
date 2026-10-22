import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../profil/profil_gate.dart';
class Inscription extends StatefulWidget {
  const Inscription({super.key});
  @override
  State<Inscription> createState() => _EtatInscription();
}

class _EtatInscription extends State<Inscription> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  final _ctrlMotDePasse = TextEditingController();
  DateTime? _dateNaissance;
  bool _enCours = false;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlMotDePasse.dispose();
    super.dispose();
  }

  int _calculerAge(DateTime naissance) {
    final maintenant = DateTime.now();
    var age = maintenant.year - naissance.year;
    if (maintenant.month < naissance.month ||
        (maintenant.month == naissance.month &&
            maintenant.day < naissance.day)) {
      age--;
    }
    return age;
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
      DateTime(maintenant.year - 15, maintenant.month, maintenant.day),
      firstDate: DateTime(maintenant.year - 100),
      lastDate: maintenant,
      helpText: 'Date de naissance',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  void _afficherMessage(String texte) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texte),
        backgroundColor: AppColors.primaryDark,
      ));

  Future<void> _continuer() async {
    if (_enCours) return;
    if (!_cleFormulaire.currentState!.validate()) return;
    if (_dateNaissance == null) {
      return _afficherMessage('Choisissez votre date de naissance');
    }
    if (_calculerAge(_dateNaissance!) >= 18) {
      return _afficherMessage('Inscription refusée : moins de 18 ans requis');
    }

    setState(() => _enCours = true);
    try {
      final email = _ctrlEmail.text.trim();
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _ctrlMotDePasse.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfilGate()),
            (route) => false,
      );

      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(cred.user!.uid)
          .set({
        'email': email,
        'dateNaissance': Timestamp.fromDate(_dateNaissance!),
        'creeLe': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _afficherMessage('Compte créé avec succès !');
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _afficherMessage('Cet email est déjà utilisé.');
          break;
        case 'weak-password':
          _afficherMessage('Mot de passe trop faible.');
          break;
        case 'invalid-email':
          _afficherMessage('Email invalide.');
          break;
        default:
          _afficherMessage('Création du compte impossible. Réessayez.');
      }
    } catch (e) {
      debugPrint('Erreur inscription: $e');
      _afficherMessage('Erreur, réessayez.');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texteDate = _dateNaissance == null
        ? 'Choisir une date'
        : '${_dateNaissance!.day.toString().padLeft(2, '0')}/'
        '${_dateNaissance!.month.toString().padLeft(2, '0')}/'
        '${_dateNaissance!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _cleFormulaire,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez renseigner vos informations ci-dessous.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ctrlEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                  Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ctrlMotDePasse,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon:
                  Icon(Icons.lock_outline, color: AppColors.primary),
                ),
                validator: (v) =>
                (v == null || v.length < 6) ? '6 caractères minimum' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _choisirDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary),
                  ),
                  child: Text(
                    texteDate,
                    style: TextStyle(
                      color: _dateNaissance == null
                          ? Colors.black45
                          : AppColors.primaryDark,
                      fontWeight: _dateNaissance == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _enCours ? null : _continuer,
                  child: _enCours
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Créer mon compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}