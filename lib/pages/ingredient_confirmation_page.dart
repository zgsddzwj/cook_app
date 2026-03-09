import '../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../models/ingredient.dart';
import 'recipe_detail_page.dart';

class IngredientConfirmationPage extends StatefulWidget {
  final String imagePath;
  final List<Ingredient> initialIngredients;

  const IngredientConfirmationPage({
    super.key,
    required this.imagePath,
    required this.initialIngredients,
  });

  @override
  State<IngredientConfirmationPage> createState() => _IngredientConfirmationPageState();
}

class _IngredientConfirmationPageState extends State<IngredientConfirmationPage> {
  late List<Ingredient> _ingredients;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.initialIngredients);
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addIngredient(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _ingredients.add(Ingredient(
        name: name.trim(),
        amount: '1',
        category: '其他',
      ));
    });
    _addController.clear();
  }

  void _showPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PreferencesBottomSheet(
        onConfirm: (prefs) {
          Navigator.pop(context);
          _generateRecipe(prefs);
        },
      ),
    );
  }

  Future<void> _generateRecipe(Map<String, dynamic> prefs) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final recipe = await LLMService.generateRecipe(_ingredients, prefs);
      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(
              id: recipe['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: recipe['title'],
              imageUrl: recipe['imageUrl'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
              tags: List<String>.from(recipe['tags']),
              time: recipe['time'],
              calories: recipe['calories'],
              description: recipe['description'],
              ingredients: List<Map<String, String>>.from(
                (recipe['ingredients'] as List).map((i) => Map<String, String>.from(i))
              ),
              steps: List<String>.from(recipe['steps']),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成食谱失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.confirmIngredients),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Upper part: Image
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Lower part: Tags and Editing
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recognizedIngredients,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: [
                          ..._ingredients.asMap().entries.map((entry) {
                            return Chip(
                              label: Text(entry.value.name),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              labelStyle: const TextStyle(color: AppColors.primary),
                              deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                              onDeleted: () => _removeIngredient(entry.key),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            );
                          }),
                          // Add manual button
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16, color: Colors.white),
                            label: Text(l10n.addManually),
                            backgroundColor: AppColors.primary,
                            labelStyle: const TextStyle(color: Colors.white),
                            onPressed: () {
                              _showAddDialog();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _ingredients.isEmpty ? null : _showPreferencesSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.generateRecipe,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addIngredient),
        content: TextField(
          controller: _addController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.ingredientNameHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            _addIngredient(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _addIngredient(_addController.text);
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _PreferencesBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirm;

  const _PreferencesBottomSheet({required this.onConfirm});

  @override
  State<_PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<_PreferencesBottomSheet> {
  String _time = '不限';
  String _flavor = '清淡';
  String _equipment = '不限';

  final List<String> _times = ['15分钟内', '30分钟', '不限'];
  final List<String> _flavors = ['清淡', '嗜辣', '减脂', '增肌'];
  final List<String> _equipments = ['仅用微波炉', '仅用平底锅', '烤箱可用', '不限'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.preferences,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionGroup(l10n.cookingTimePref, _times, _time, (val) => setState(() => _time = val)),
          const SizedBox(height: 24),
          _buildOptionGroup(l10n.flavorPref, _flavors, _flavor, (val) => setState(() => _flavor = val)),
          const SizedBox(height: 24),
          _buildOptionGroup(l10n.equipmentPref, _equipments, _equipment, (val) => setState(() => _equipment = val)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm({
                'time': _time,
                'flavor': _flavor,
                'equipment': _equipment,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.startAICreation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(String title, List<String> options, String current, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == current;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelect(opt);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              backgroundColor: Colors.grey[100],
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
