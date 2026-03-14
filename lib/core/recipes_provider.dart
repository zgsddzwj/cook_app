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
      // 分别获取数据，即使一个失败也不会影响其他
      List<Meal> randomMeals = [];
      List<Meal> seafoodMeals = [];
      List<Meal> vegetarianMeals = [];
      
      try {
        randomMeals = await _mealDbService.getRandomMeals(8);
      } catch (e) {
        debugPrint('Error loading random meals: $e');
      }
      
      try {
        seafoodMeals = await _mealDbService.filterByCategory('Seafood');
      } catch (e) {
        debugPrint('Error loading seafood meals: $e');
      }
      
      try {
        vegetarianMeals = await _mealDbService.filterByCategory('Vegetarian');
      } catch (e) {
        debugPrint('Error loading vegetarian meals: $e');
      }
      
      // 合并并去重
      final allMeals = <Meal>{};
      allMeals.addAll(randomMeals);
      allMeals.addAll(seafoodMeals.take(5));
      allMeals.addAll(vegetarianMeals.take(5));
      
      if (allMeals.isEmpty) {
        error = '暂无食谱数据，请检查网络连接后重试';
        isLoading = false;
        notifyListeners();
        return;
      }
      
      // 获取已收藏的食谱ID
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      // 转换为 Recipe 模型
      _apiRecipes = allMeals.map((meal) => _convertMealToRecipe(meal, favoriteIds)).toList();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = '加载食谱失败: $e';
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
      error = '搜索失败: $e';
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
      error = '筛选失败: $e';
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
      isFavorite: favoriteIds.contains(meal.id),
    );
  }

  /// 将英文分类翻译为中文
  String _translateCategory(String category) {
    const translations = {
      'Beef': '牛肉',
      'Breakfast': '早餐',
      'Chicken': '鸡肉',
      'Dessert': '甜点',
      'Goat': '羊肉',
      'Lamb': '羊肉',
      'Miscellaneous': '其他',
      'Pasta': '意面',
      'Pork': '猪肉',
      'Seafood': '海鲜',
      'Side': '配菜',
      'Starter': '开胃菜',
      'Vegan': '纯素食',
      'Vegetarian': '素食',
    };
    return translations[category] ?? category;
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
