import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/meal_db_service.dart';
import '../core/recipes_provider.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';
import 'related_recipes_page.dart';

class IngredientDetailPage extends StatefulWidget {
  final Ingredient ingredient;

  const IngredientDetailPage({super.key, required this.ingredient});

  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  final MealDbService _mealDbService = MealDbService();
  List<Recipe> _relatedRecipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRelatedRecipes();
  }

  /// 中文食材名称映射到英文（TheMealDB 使用英文）
  static const Map<String, String> _ingredientMapping = {
    '鸡肉': 'Chicken',
    '鸡胸肉': 'Chicken',
    '鸡腿': 'Chicken',
    '牛肉': 'Beef',
    '猪肉': 'Pork',
    '羊肉': 'Lamb',
    '鱼': 'Salmon',
    '三文鱼': 'Salmon',
    '虾': 'Shrimp',
    '鸡蛋': 'Eggs',
    '番茄': 'Tomato',
    '西红柿': 'Tomato',
    '土豆': 'Potato',
    '马铃薯': 'Potato',
    '胡萝卜': 'Carrots',
    '洋葱': 'Onion',
    '大蒜': 'Garlic',
    '菠菜': 'Spinach',
    '生菜': 'Lettuce',
    '白菜': 'Cabbage',
    '西兰花': 'Broccoli',
    '花椰菜': 'Cauliflower',
    '黄瓜': 'Cucumber',
    '茄子': 'Eggplant',
    '辣椒': 'Pepper',
    '青椒': 'Pepper',
    '蘑菇': 'Mushrooms',
    '豆腐': 'Tofu',
    '牛奶': 'Milk',
    '黄油': 'Butter',
    '奶酪': 'Cheese',
    '奶油': 'Cream',
    '酸奶': 'Yogurt',
    '面粉': 'Flour',
    '米饭': 'Rice',
    '面条': 'Pasta',
    '意大利面': 'Pasta',
    '面包': 'Bread',
    '柠檬': 'Lemon',
    '橙子': 'Orange',
    '苹果': 'Apple',
    '香蕉': 'Banana',
    '草莓': 'Strawberries',
    '蓝莓': 'Blueberries',
    '牛油果': 'Avocado',
    '橄榄油': 'Olive Oil',
    '油': 'Oil',
    '盐': 'Salt',
    '糖': 'Sugar',
    '酱油': 'Soy Sauce',
    '醋': 'Vinegar',
    '蜂蜜': 'Honey',
  };

  Future<void> _loadRelatedRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final List<Recipe> recipes = [];

    try {
      // 1. 首先尝试从 API 获取（使用英文映射）
      final englishName = _ingredientMapping[widget.ingredient.name];
      if (englishName != null) {
        try {
          final meals = await _mealDbService.filterByIngredient(englishName);
          debugPrint('API returned ${meals.length} meals for ${widget.ingredient.name} ($englishName)');

          // 获取详情（分批处理，避免过多请求）
          for (final meal in meals.take(3)) {
            try {
              final detail = await _mealDbService.getMealById(meal.id);
              if (detail != null) {
                recipes.add(_convertMealToRecipe(detail));
              }
            } catch (e) {
              debugPrint('Error getting meal detail: $e');
            }
          }
        } catch (e) {
          debugPrint('Error filtering by ingredient: $e');
        }
      } else {
        debugPrint('No English mapping for ${widget.ingredient.name}, skipping API call');
      }

      // 2. 从本地食谱中匹配
      final provider = Provider.of<RecipesProvider>(context, listen: false);
      final localRecipes = provider.recipes.where((recipe) {
        return recipe.ingredients.any((ing) {
          final recipeIngredientName = ing['name']?.toLowerCase() ?? '';
          final currentIngredientName = widget.ingredient.name.toLowerCase();
          return recipeIngredientName.contains(currentIngredientName) ||
              currentIngredientName.contains(recipeIngredientName);
        });
      }).toList();
      debugPrint('Found ${localRecipes.length} local recipes containing ${widget.ingredient.name}');

      // 合并结果，去重
      final existingIds = recipes.map((r) => r.id).toSet();
      for (final recipe in localRecipes) {
        if (!existingIds.contains(recipe.id)) {
          recipes.add(recipe);
          existingIds.add(recipe.id);
        }
      }

      setState(() {
        _relatedRecipes = recipes;
        _isLoading = false;
        if (recipes.isEmpty) {
          _error = AppLocalizations.of(context)!.noRecipesFound;
        }
      });
    } catch (e) {
      debugPrint('Error loading related recipes: $e');
      setState(() {
        _isLoading = false;
        _error = '加载失败: $e';
      });
    }
  }

  Recipe _convertMealToRecipe(Meal meal) {
    final tags = <String>[];
    if (meal.category.isNotEmpty && meal.category != 'Unknown') {
      tags.add(meal.category);
    }
    if (meal.area.isNotEmpty && meal.area != 'Unknown') {
      tags.add(meal.area);
    }
    tags.addAll(meal.tagList.take(3));

    final ingredients = meal.ingredients
        .map((ing) => {'name': ing.name, 'amount': ing.measure})
        .toList();

    final steps = meal.instructions
        .split('\r\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final finalSteps = steps.isEmpty || steps.length == 1
        ? _splitInstructions(meal.instructions)
        : steps;

    return Recipe(
      id: meal.id,
      title: meal.name,
      description: meal.shortDescription.isNotEmpty
          ? meal.shortDescription
          : '${meal.category}食谱，来自${meal.area}',
      time: meal.estimatedTime,
      calories: meal.estimatedCalories,
      imageUrl: meal.thumbnail ?? 'https://via.placeholder.com/500x300?text=No+Image',
      tags: tags,
      ingredients: ingredients,
      steps: finalSteps,
    );
  }

  List<String> _splitInstructions(String instructions) {
    if (instructions.isEmpty) return [];
    final lines = instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (lines.length > 1) return lines;
    return instructions
        .split(RegExp(r'[.!?。！？]\s+'))
        .where((s) => s.trim().length > 5)
        .map((s) => s.trim() + (s.endsWith('.') ? '' : '.'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              title: Text(
                widget.ingredient.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(context, l10n),
                const SizedBox(height: 24),
                _buildNutritionSection(context, l10n),
                const SizedBox(height: 24),
                _buildStorageSection(context, l10n),
                const SizedBox(height: 24),
                _buildRelatedRecipesSection(context, l10n),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoColumn(l10n.pantry, widget.ingredient.category),
          Container(width: 1, height: 40, color: Colors.grey.shade100),
          _buildInfoColumn(AppLocalizations.of(context)!.myIngredients, widget.ingredient.amount),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nutritionInfo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildNutritionRow(l10n.caloriesPer100g, '165 kcal'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionItem(l10n.protein, '31g'),
                  _buildNutritionItem(l10n.carbs, '0g'),
                  _buildNutritionItem(l10n.fat, '3.6g'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.storageTips,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildStorageRow(Icons.ac_unit, l10n.fridgeLife, '3-5 天'),
              const Divider(height: 24),
              _buildStorageRow(Icons.kitchen, AppLocalizations.of(context)!.pantryLife, '6-9 months'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRelatedRecipesSection(BuildContext context, AppLocalizations l10n) {
    final displayRecipes = _relatedRecipes.take(3).toList();
    final hasMore = _relatedRecipes.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.relatedRecipes,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (hasMore)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatedRecipesPage(
                        ingredient: widget.ingredient,
                        recipes: _relatedRecipes,
                      ),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.viewMore, style: const TextStyle(color: AppColors.primary)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_relatedRecipes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.grey, size: 32),
                const SizedBox(height: 8),
                Text(
                  _error ?? AppLocalizations.of(context)!.noRecipesFound,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadRelatedRecipes,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(AppLocalizations.of(context)!.reload),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ...displayRecipes.map((recipe) => _buildRecipeCard(context, recipe)),
              if (hasMore)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RelatedRecipesPage(
                          ingredient: widget.ingredient,
                          recipes: _relatedRecipes,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.viewMore,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailPage(
              id: recipe.id,
              title: recipe.title,
              imageUrl: recipe.imageUrl,
              tags: recipe.tags,
              time: recipe.time,
              calories: recipe.calories,
              description: recipe.description,
              ingredients: recipe.ingredients,
              steps: recipe.steps,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                recipe.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.time}分钟',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories}千卡',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
