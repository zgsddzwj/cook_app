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

  @override
  void initState() {
    super.initState();
    _loadRelatedRecipes();
  }

  Future<void> _loadRelatedRecipes() async {
    setState(() => _isLoading = true);
    
    try {
      // 尝试用食材名称从 API 获取相关食谱
      final meals = await _mealDbService.filterByIngredient(widget.ingredient.name);
      
      // 获取详情
      final List<Recipe> recipes = [];
      for (final meal in meals.take(5)) {
        final detail = await _mealDbService.getMealById(meal.id);
        if (detail != null) {
          recipes.add(_convertMealToRecipe(detail));
        }
      }
      
      // 如果 API 没有返回结果，尝试用本地数据匹配
      if (recipes.isEmpty) {
        final provider = Provider.of<RecipesProvider>(context, listen: false);
        final localRecipes = provider.recipes.where((recipe) {
          return recipe.ingredients.any((ing) {
            final recipeIngredientName = ing['name']?.toLowerCase() ?? '';
            final currentIngredientName = widget.ingredient.name.toLowerCase();
            return recipeIngredientName.contains(currentIngredientName) ||
                   currentIngredientName.contains(recipeIngredientName);
          });
        }).toList();
        recipes.addAll(localRecipes);
      }
      
      setState(() {
        _relatedRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          _buildInfoColumn('当前数量', widget.ingredient.amount),
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
              _buildStorageRow(Icons.kitchen, '冷冻建议', '6-9 个月'),
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
                child: const Text('查看更多', style: TextStyle(color: AppColors.primary)),
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
        else if (displayRecipes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.grey),
                SizedBox(width: 12),
                Text(
                  '暂无相关食谱',
                  style: TextStyle(color: AppColors.textSecondary),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '查看更多食谱',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
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
