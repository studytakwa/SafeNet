import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import '../../services/category_service.dart';
import '../../theme/app_theme.dart';
import '../Home/widgets/home_common.dart';
import '../widgets/dynamic_category_field.dart';

class _QuestionForm {
  final texte = TextEditingController();
  final options = List.generate(4, (_) => TextEditingController());
  int bonne = 0;
}

class CreateQuizView extends StatefulWidget {
  final String? groupeId;
  const CreateQuizView({super.key, this.groupeId});

  @override
  State<CreateQuizView> createState() => _CreateQuizViewState();
}

class _CreateQuizViewState extends State<CreateQuizView> {
  final _controller = QuizController();
  final _titre = TextEditingController();
  final _forms = <_QuestionForm>[_QuestionForm()];
  String _categorie = 'Sciences';
  bool _loading = false;

  Future<void> _publier() async {
    if (_titre.text.trim().isEmpty) {
      _msg('Donnez un titre à votre quiz.');
      return;
    }
    final questions = <QuestionQuiz>[];
    for (final f in _forms) {
      final opts = f.options.map((c) => c.text.trim()).toList();
      if (f.texte.text.trim().isEmpty || opts.any((o) => o.isEmpty)) {
        _msg('Remplissez toutes les questions et les 4 options.');
        return;
      }
      questions.add(QuestionQuiz(
          texte: f.texte.text.trim(), options: opts, bonneReponse: f.bonne));
    }
    setState(() => _loading = true);
    await CategoryService().ajouterCategorie(_categorie);
    final code = await _controller.creerQuiz(
      titre: _titre.text.trim(),
      categorie: _categorie,
      questions: questions,
      groupeId: widget.groupeId,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primaryDark),
            SizedBox(width: 8),
            Text('Quiz créé !',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Partagez ce code d\'accès avec vos amis :'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mintContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t),
          backgroundColor: Colors.redAccent,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: const Text(
          'Créer un quiz',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: HomeColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titre,
                    decoration: InputDecoration(
                      labelText: 'Titre du quiz',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DynamicCategoryField(
                    selectedCategory: _categorie,
                    onCategoryChanged: (v) => setState(() => _categorie = v),
                    label: 'Catégorie',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _forms.length; i++) _buildQuestion(i),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => setState(() => _forms.add(_QuestionForm())),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une question',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _loading ? null : _publier,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Publier le quiz',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuestion(int i) {
    final f = _forms[i];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HomeColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Question ${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                if (_forms.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => setState(() => _forms.removeAt(i)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.texte,
              decoration: InputDecoration(
                labelText: 'Énoncé de la question',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Options de réponse (cochez la bonne réponse) :',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: HomeColors.mute,
              ),
            ),
            const SizedBox(height: 8),
            for (int j = 0; j < 4; j++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Radio<int>(
                      value: j,
                      groupValue: f.bonne,
                      activeColor: AppColors.primaryDark,
                      onChanged: (v) => setState(() => f.bonne = v!),
                    ),
                    Expanded(
                      child: TextField(
                        controller: f.options[j],
                        decoration: InputDecoration(
                          hintText: 'Option ${j + 1}',
                          filled: true,
                          fillColor: f.bonne == j
                              ? AppColors.mintContainer.withValues(alpha: 0.5)
                              : AppColors.background,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: f.bonne == j
                                  ? AppColors.primary
                                  : HomeColors.line,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
