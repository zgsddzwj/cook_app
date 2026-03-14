import '../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:async';
import '../core/app_colors.dart';
import '../core/navigation_provider.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../core/recipes_provider.dart';
import '../core/scan_history_provider.dart';
import 'recipe_detail_page.dart';
import 'generated_recipes_page.dart';

class IngredientConfirmationPage extends StatefulWidget {
  final List<String> imagePaths;
  final List<Ingredient> initialIngredients;
  final String? scanHistoryId; // 添加扫描历史ID

  const IngredientConfirmationPage({
    super.key,
    required this.imagePaths,
    required this.initialIngredients,
    this.scanHistoryId,
  });

  @override
  State<IngredientConfirmationPage> createState() =>
      _IngredientConfirmationPageState();
}

class _IngredientConfirmationPageState
    extends State<IngredientConfirmationPage> {
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

  void _addIngredient(String name, String amount) {
    if (name.trim().isEmpty) return;
    setState(() {
      _ingredients.add(Ingredient(
        name: name.trim(),
        amount: amount.trim().isEmpty ? '1' : amount.trim(),
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
      builder: (context) => _LoadingDialog(),
    );

    try {
      final recipeData = await LLMService.generateRecipe(_ingredients, prefs);
      if (mounted) {
        final recipesProvider =
            Provider.of<RecipesProvider>(context, listen: false);
        final historyProvider =
            Provider.of<ScanHistoryProvider>(context, listen: false);

        final List<dynamic> recipesList = recipeData['recipes'] ?? [];
        if (recipesList.isEmpty) {
          throw RecipeGenerationException(
            message: '未能生成有效食谱',
            suggestion: '请尝试添加更多食材',
          );
        }

        final List<Recipe> generatedRecipes = [];

        for (var data in recipesList) {
          final newRecipe = Recipe(
            id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: data['title'],
            imageUrl: data['imageUrl'] ??
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
            tags: List<String>.from(data['tags']),
            time: data['time'],
            calories: data['calories'],
            description: data['description'],
            ingredients: List<Map<String, String>>.from(
                (data['ingredients'] as List)
                    .map((i) => Map<String, String>.from(i))),
            steps: List<String>.from(data['steps']),
            isFavorite: true,
          );
          generatedRecipes.add(newRecipe);
          recipesProvider.addRecipe(newRecipe);
        }

        // 如果有关联的扫描历史，更新它（由于可能生成多个，这里简单关联第一个，或者后续可以优化模型支持多关联）
        if (widget.scanHistoryId != null && generatedRecipes.isNotEmpty) {
          historyProvider.updateEntryRecipe(
              widget.scanHistoryId!, generatedRecipes.first);
        }

        Navigator.pop(context); // Close loading

        if (generatedRecipes.length == 1) {
          // 只有一道菜，直接去详情
          final r = generatedRecipes.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(
                id: r.id,
                title: r.title,
                imageUrl: r.imageUrl,
                tags: r.tags,
                time: r.time,
                calories: r.calories,
                description: r.description,
                ingredients: r.ingredients,
                steps: r.steps,
              ),
            ),
          );
        } else {
          // 多道菜，跳转到新的识别食谱列表页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GeneratedRecipesPage(recipes: generatedRecipes),
            ),
          );
          Fluttertoast.showToast(
            msg: '已为您生成 ${generatedRecipes.length} 道精选食谱！',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: AppColors.primary,
            gravity: ToastGravity.TOP,
          );
        }
      }
    } on RecipeGenerationException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showErrorDialog('无法生成食谱', '${e.message}\n\n建议：${e.suggestion}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        final errorMsg = AppLocalizations.of(context)?.generateRecipeFailed(e.toString()) ?? 'Failed to generate recipe: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)?.iGotIt ?? 'I Got It',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

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
          // Upper part: Image Gallery
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: widget.imagePaths.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePaths[index])),
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
                      );
                    },
                  ),
                  if (widget.imagePaths.length > 1)
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.imagePaths.length} 张图片',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                            final ingredient = entry.value;
                            return Chip(
                              label: Text(
                                '${ingredient.name}${ingredient.amount.isNotEmpty ? " (${ingredient.amount})" : ""}',
                              ),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              labelStyle:
                                  const TextStyle(color: AppColors.primary),
                              deleteIcon: const Icon(Icons.close,
                                  size: 16, color: AppColors.primary),
                              onDeleted: () => _removeIngredient(entry.key),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            );
                          }),
                          // Add manual button
                          ActionChip(
                            avatar: const Icon(Icons.add,
                                size: 16, color: Colors.white),
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
                          onPressed: _ingredients.isEmpty
                              ? null
                              : _showPreferencesSheet,
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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addIngredient),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.ingredientNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: '数量 (如: 500g, 2个)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _addIngredient(nameController.text, amountController.text);
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
  State<_PreferencesBottomSheet> createState() =>
      _PreferencesBottomSheetState();
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
          _buildOptionGroup(l10n.cookingTimePref, _times, _time,
              (val) => setState(() => _time = val)),
          const SizedBox(height: 24),
          _buildOptionGroup(l10n.flavorPref, _flavors, _flavor,
              (val) => setState(() => _flavor = val)),
          const SizedBox(height: 24),
          _buildOptionGroup(l10n.equipmentPref, _equipments, _equipment,
              (val) => setState(() => _equipment = val)),
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

  Widget _buildOptionGroup(String title, List<String> options, String current,
      Function(String) onSelect) {
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

class _LoadingDialog extends StatefulWidget {
  @override
  State<_LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog> {
  int _messageIndex = 0;
  final List<String> _messages = [
    '正在思考最适合您的搭配...',
    '正在为您编写烹饪步骤...',
    '正在调配美味的调料建议...',
    '正在计算营养成分...',
    '大厨正在为您润色食谱...',
    '即将为您呈现美味...',
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                _messages[_messageIndex],
                key: ValueKey<int>(_messageIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
