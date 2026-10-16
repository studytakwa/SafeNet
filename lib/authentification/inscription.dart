import 'package:flutter/material.dart';
import 'selfie.dart';

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
  bool _consentement = false;

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
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  void _afficherMessage(String texte) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));

  void _continuer() {
    if (!_cleFormulaire.currentState!.validate()) return;
    if (_dateNaissance == null) {
      return _afficherMessage('Choisissez votre date de naissance');
    }
    if (_calculerAge(_dateNaissance!) >= 18) {
      return _afficherMessage('Inscription refusée : réservé aux moins de 18 ans');
    }
    if (!_consentement) {
      return _afficherMessage('Vous devez accepter le consentement');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Selfie(
          email: _ctrlEmail.text.trim(),
          motDePasse: _ctrlMotDePasse.text,
          dateNaissance: _dateNaissance!,
        ),
      ),
    );
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
            children: [
              TextFormField(
                controller: _ctrlEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ctrlMotDePasse,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Mot de passe', border: OutlineInputBorder()),
                validator: (v) =>
                (v == null || v.length < 6) ? '6 caractères minimum' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _choisirDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(texteDate),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _consentement,
                onChanged: (v) => setState(() => _consentement = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'Nous analysons votre visage pour vérifier votre âge.'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continuer,
                  child: const Text('Continuer : selfie obligatoire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}