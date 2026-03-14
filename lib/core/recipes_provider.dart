import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe.dart';
import 'meal_db_service.dart';

class RecipesProvider extends ChangeNotifier {
  final MealDbService _mealDbService = MealDbService();
  
  // API 获取的食谱
  List<Recipe> _apiRecipes = [];
  // 用户自定义食谱
  final List<Recipe> _customRecipes = [];
  static const String _storageKey = 'custom_recipes';
  static const String _favoritesKey = 'favorite_recipe_ids';

  // 加载状态
  bool isLoading = false;
  String? error;

  RecipesProvider() {
    _loadCustomRecipes();
    // 启动时从 API 加载食谱
    loadRecipesFromApi();
  }

  List<Recipe> get recipes => [..._customRecipes, ..._apiRecipes];
  
  List<Recipe> get favoriteRecipes =>
      recipes.where((r) => r.isFavorite).toList();

  /// 从 TheMealDB API 加载食谱
  Future<void> loadRecipesFromApi() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Only use getRandomMeals which returns complete data
      // filterByCategory/filterByArea return incomplete data (id, name, thumbnail only)
      List<Meal> randomMeals = [];
      
      try {
        randomMeals = await _mealDbService.getRandomMeals(15);
      } catch (e) {
        debugPrint('Error loading random meals: $e');
      }
      
      if (randomMeals.isEmpty) {
        error = 'No recipe data available. Please check your network connection and try again.';
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // 获取已收藏的食谱ID
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      // 转换为 Recipe 模型
      _apiRecipes = randomMeals.map((meal) => _convertMealToRecipe(meal, favoriteIds)).toList();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load recipes: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索食谱
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) {
      await loadRecipesFromApi();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final meals = await _mealDbService.searchMeals(query);
      
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      _apiRecipes = meals.map((meal) => _convertMealToRecipe(meal, favoriteIds)).toList();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Search failed: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// 按食材筛选食谱
  Future<void> filterByIngredient(String ingredient) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final meals = await _mealDbService.filterByIngredient(ingredient);
      
      // filter 接口返回的数据不完整，需要获取详情
      final List<Meal> detailedMeals = [];
      for (final meal in meals.take(10)) {
        final detail = await _mealDbService.getMealById(meal.id);
        if (detail != null) {
          detailedMeals.add(detail);
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      _apiRecipes = detailedMeals.map((meal) => _convertMealToRecipe(meal, favoriteIds)).toList();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Filter failed: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// 将 Meal 转换为 Recipe
  Recipe _convertMealToRecipe(Meal meal, List<String> favoriteIds) {
    // 构建标签列表
    final tags = <String>[];
    if (meal.category.isNotEmpty && meal.category != 'Unknown') {
      // 将英文分类映射为中文
      tags.add(_translateCategory(meal.category));
    }
    if (meal.area.isNotEmpty && meal.area != 'Unknown') {
      tags.add(meal.area);
    }
    tags.addAll(meal.tagList.take(3));

    // 构建食材列表
    final ingredients = meal.ingredients
        .map((ing) => {
              'name': ing.name,
              'amount': ing.measure,
            })
        .toList();

    // 构建步骤列表
    final steps = meal.instructions
        .split('\r\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // 如果步骤为空或格式不对，尝试按数字分割
    final finalSteps = steps.isEmpty || steps.length == 1
        ? _splitInstructions(meal.instructions)
        : steps;

    // Build description
    String description = meal.shortDescription;
    if (description.isEmpty && meal.category != 'Unknown') {
      description = 'A delicious ${meal.category} recipe';
      if (meal.area != 'Unknown') {
        description += ' from ${meal.area}';
      }
    } else if (description.isEmpty) {
      description = 'A delicious recipe with ${ingredients.length} ingredients';
    }

    return Recipe(
      id: meal.id,
      title: meal.name,
      description: description,
      time: meal.estimatedTime,
      calories: meal.estimatedCalories,
      imageUrl: meal.thumbnail ?? 'https://via.placeholder.com/500x300?text=No+Image',
      tags: tags.isNotEmpty ? tags : ['Recipe'],
      ingredients: ingredients.isNotEmpty ? ingredients : [],
      steps: finalSteps.isNotEmpty ? finalSteps : ['No instructions available'],
      isFavorite: favoriteIds.contains(meal.id),
    );
  }

  /// Keep category names in English for US users
  String _translateCategory(String category) {
    return category;
  }

  /// 智能分割烹饪步骤
  List<String> _splitInstructions(String instructions) {
    if (instructions.isEmpty) return [];
    
    // 按换行分割
    final lines = instructions
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    
    if (lines.length > 1) return lines;
    
    // 如果只有一行，尝试按句号分割
    return instructions
        .split(RegExp(r'[.!?。！？]\s+'))
        .where((s) => s.trim().length > 5)
        .map((s) => s.trim() + (s.endsWith('.') ? '' : '.'))
        .toList();
  }

  Future<void> _loadCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recipesJson = prefs.getString(_storageKey);
      if (recipesJson != null) {
        final List<dynamic> decoded = jsonDecode(recipesJson);
        _customRecipes.clear();
        _customRecipes.addAll(decoded.map((item) => Recipe.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading custom recipes: $e');
    }
  }

  Future<void> _saveCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_customRecipes.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving custom recipes: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = recipes
          .where((r) => r.isFavorite)
          .map((r) => r.id)
          .toList();
      await prefs.setStringList(_favoritesKey, favoriteIds);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void toggleFavorite(String id) {
    // 检查是否是自定义食谱
    final customIndex = _customRecipes.indexWhere((r) => r.id == id);
    if (customIndex != -1) {
      _customRecipes[customIndex].isFavorite =
          !_customRecipes[customIndex].isFavorite;
      _saveCustomRecipes();
      _saveFavorites();
      notifyListeners();
      return;
    }

    // 检查是否是API食谱
    final apiIndex = _apiRecipes.indexWhere((r) => r.id == id);
    if (apiIndex != -1) {
      _apiRecipes[apiIndex].isFavorite = !_apiRecipes[apiIndex].isFavorite;
      _saveFavorites();
      notifyListeners();
    }
  }

  bool isFavorite(String id) {
    return recipes.any((r) => r.id == id && r.isFavorite);
  }

  void addRecipe(Recipe recipe) {
    if (!recipes.any((r) => r.id == recipe.id)) {
      _customRecipes.insert(0, recipe);
      _saveCustomRecipes();
      notifyListeners();
    }
  }
}
