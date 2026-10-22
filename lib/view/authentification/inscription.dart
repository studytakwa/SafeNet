import 'package:flutter/material.dart';
import '../../controllers/inscription_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/Auth layout.dart';
import 'connexion.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _EtatInscription();
}

class _EtatInscription extends State<Inscription> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  final _ctrlMotDePasse = TextEditingController();
  final _controller = InscriptionController();

  DateTime? _dateNaissance;
  bool _enCours = false;
  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlMotDePasse.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(maintenant.year - 15, maintenant.month, maintenant.day),
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

  void _afficherMessage(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texte),
      backgroundColor: AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  Future<void> _continuer() async {
    if (_enCours) return;
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() => _enCours = true);

    final erreur = await _controller.inscrire(
      email: _ctrlEmail.text,
      motDePasse: _ctrlMotDePasse.text,
      dateNaissance: _dateNaissance,
    );

    if (!mounted) return;
    setState(() => _enCours = false);

    if (erreur == null) {
      _afficherMessage('Compte créé avec succès !');
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      _afficherMessage(erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texteDate = _dateNaissance == null
        ? 'Choisir une date'
        : '${_dateNaissance!.day.toString().padLeft(2, '0')}/'
        '${_dateNaissance!.month.toString().padLeft(2, '0')}/'
        '${_dateNaissance!.year}';

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
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Veuillez renseigner vos informations ci-dessous.',
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
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Email invalide'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ctrlMotDePasse,
                    obscureText: _masquerMotDePasse,
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
                    validator: (v) => (v == null || v.length < 6)
                        ? '6 caractères minimum'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _choisirDate,
                    borderRadius: BorderRadius.circular(30),
                    child: InputDecorator(
                      decoration: champDecoration(
                        label: 'Date de naissance',
                        icone: Icons.calendar_today_outlined,
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
                  ElevatedButton(
                    style: styleBoutonPrincipal(),
                    onPressed: _enCours ? null : _continuer,
                    child: _enCours
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Créer mon compte'),
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
                'Déjà un compte ?',
                style: TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnexionPage()),
                ),
                child: const Text(
                  'Se connecter',
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
