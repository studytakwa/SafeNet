import 'package:flutter/material.dart';
import '../../controllers/admin_auth_controller.dart';
import '../Home/widgets/home_common.dart';
import 'admin_shell.dart';

/// Connexion réservée à l'administrateur (e-mail + mot de passe).
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _ctrl = AdminAuthController();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _mdp = TextEditingController();
  bool _masque = true;
  bool _loading = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    // Administrateur déjà connecté : on l'envoie directement à son espace.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _ctrl.dejaConnecteAdmin() && mounted) _allerEspaceAdmin();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _mdp.dispose();
    super.dispose();
  }

  void _allerEspaceAdmin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminShell()),
    );
  }

  Future<void> _connexion() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _erreur = null;
    });
    final erreur = await _ctrl.seConnecter(_email.text, _mdp.text);
    if (!mounted) return;
    if (erreur == null) {
      _allerEspaceAdmin();
    } else {
      setState(() {
        _loading = false;
        _erreur = erreur;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: HomeColors.ink,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: HomeColors.line),
              ),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: HomeColors.brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined,
                            color: Colors.white, size: 34),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Espace administrateur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: HomeColors.ink)),
                    const SizedBox(height: 4),
                    const Text('Accès réservé à l\'administrateur de SafeNet',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HomeColors.mute)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Saisissez votre e-mail';
                        if (!t.contains('@')) return 'E-mail invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mdp,
                      obscureText: _masque,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _connexion(),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_masque
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _masque = !_masque),
                        ),
                      ),
                      validator: (v) => (v ?? '').isEmpty
                          ? 'Saisissez votre mot de passe'
                          : null,
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFD64545), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_erreur!,
                                    style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.brand,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loading ? null : _connexion,
                      child: _loading
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Text('Se connecter',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}