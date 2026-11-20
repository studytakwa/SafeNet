import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../theme/app_theme.dart';

class DynamicCategoryField extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final String label;

  const DynamicCategoryField({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.label = 'Catégorie / Matière',
  });

  @override
  State<DynamicCategoryField> createState() => _DynamicCategoryFieldState();
}

class _DynamicCategoryFieldState extends State<DynamicCategoryField> {
  final _categoryService = CategoryService();
  List<String> _categories = [];
  bool _loading = true;
  bool _saisieLibre = false;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final list = await _categoryService.chargerCategories();
    if (!mounted) return;
    setState(() {
      _categories = list;
      if (!_categories.contains(widget.selectedCategory) && widget.selectedCategory.isNotEmpty) {
        _categories.add(widget.selectedCategory);
        _categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
      _loading = false;
    });
  }

  Future<void> _ajouterNouvelle(String nouvelle) async {
    final trim = nouvelle.trim();
    if (trim.isEmpty) return;
    await _categoryService.ajouterCategorie(trim);
    widget.onCategoryChanged(trim);
    await _charger();
    setState(() => _saisieLibre = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LinearProgressIndicator();
    }

    if (_saisieLibre) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customController,
              decoration: InputDecoration(
                labelText: 'Saisir une nouvelle ${widget.label.toLowerCase()}',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (v) => _ajouterNouvelle(v),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: () => _ajouterNouvelle(_customController.text),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => setState(() => _saisieLibre = false),
          ),
        ],
      );
    }

    String current = widget.selectedCategory;
    if (current.isEmpty && _categories.isNotEmpty) {
      current = _categories.first;
    } else if (!_categories.contains(current) && current.isNotEmpty) {
      _categories.add(current);
    }

    return DropdownButtonFormField<String>(
      initialValue: _categories.contains(current) ? current : null,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: [
        for (final c in _categories)
          DropdownMenuItem(value: c, child: Text(c)),
        const DropdownMenuItem(
          value: '__autre__',
          child: Text('+ Saisir une nouvelle...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
      onChanged: (v) {
        if (v == '__autre__') {
          setState(() => _saisieLibre = true);
        } else if (v != null) {
          widget.onCategoryChanged(v);
        }
      },
    );
  }
}
