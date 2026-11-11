import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';

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

  static const _categories = ['Sciences', 'Sport', 'Art', 'Informatique', 'Autre'];

  Future<void> _publier() async {
    if (_titre.text.trim().isEmpty) {
      _msg('Donne un titre au quiz');
      return;
    }
    final questions = <QuestionQuiz>[];
    for (final f in _forms) {
      final opts = f.options.map((c) => c.text.trim()).toList();
      if (f.texte.text.trim().isEmpty || opts.any((o) => o.isEmpty)) {
        _msg('Remplis toutes les questions et les 4 options');
        return;
      }
      questions.add(QuestionQuiz(
          texte: f.texte.text.trim(), options: opts, bonneReponse: f.bonne));
    }
    setState(() => _loading = true);
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
        title: const Text('Quiz créé !'),
        content: Text('Partage ce code avec tes amis :\n\n$code'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _titre,
              decoration: const InputDecoration(labelText: 'Titre du quiz')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _categorie,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _categorie = v!),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _forms.length; i++) _buildQuestion(i),
          TextButton.icon(
            onPressed: () => setState(() => _forms.add(_QuestionForm())),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une question'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _publier,
            child: _loading
                ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publier le quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(int i) {
    final f = _forms[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Question ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_forms.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _forms.removeAt(i)),
                ),
            ]),
            TextField(
                controller: f.texte,
                decoration: const InputDecoration(labelText: 'Énoncé')),
            RadioGroup<int>(
              groupValue: f.bonne,
              onChanged: (v) => setState(() => f.bonne = v!),
              child: Column(
                children: [
                  for (int j = 0; j < 4; j++)
                    Row(children: [
                      Radio<int>(
                        value: j,
                      ),
                      Expanded(
                        child: TextField(
                            controller: f.options[j],
                            decoration:
                            InputDecoration(labelText: 'Option ${j + 1}')),
                      ),
                    ]),
                ],
              ),
            ),
            const Text('Coche le bouton de la bonne réponse',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}