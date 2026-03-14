import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// TheMealDB API Service
/// 文档: https://www.themealdb.com/api.php
class MealDbService {
  static final MealDbService _instance = MealDbService._internal();
  factory MealDbService() => _instance;
  MealDbService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// 按名称搜索食谱
  /// 示例: searchMeals("Arrabiata")
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await _dio.get('/search.php', queryParameters: {'s': query});
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error searching meals: $e');
      return [];
    }
  }

  /// 按首字母列出食谱
  /// 示例: listMealsByFirstLetter("a")
  Future<List<Meal>> listMealsByFirstLetter(String letter) async {
    try {
      final response = await _dio.get('/search.php', queryParameters: {'f': letter});
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error listing meals: $e');
      return [];
    }
  }

  /// 通过ID获取食谱详情
  /// 示例: getMealById("52772")
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await _dio.get('/lookup.php', queryParameters: {'i': id});
      final meals = _parseMeals(response.data);
      return meals.isNotEmpty ? meals.first : null;
    } catch (e) {
      debugPrint('Error getting meal by id: $e');
      return null;
    }
  }

  /// 获取随机食谱
  Future<Meal?> getRandomMeal() async {
    try {
      final response = await _dio.get('/random.php');
      final meals = _parseMeals(response.data);
      return meals.isNotEmpty ? meals.first : null;
    } catch (e) {
      debugPrint('Error getting random meal: $e');
      return null;
    }
  }

  /// 按食材筛选食谱
  /// 示例: filterByIngredient("chicken")
  Future<List<Meal>> filterByIngredient(String ingredient) async {
    try {
      final response = await _dio.get('/filter.php', queryParameters: {'i': ingredient});
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by ingredient: $e');
      return [];
    }
  }

  /// 按分类筛选食谱
  /// 示例: filterByCategory("Seafood")
  Future<List<Meal>> filterByCategory(String category) async {
    try {
      final response = await _dio.get('/filter.php', queryParameters: {'c': category});
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by category: $e');
      return [];
    }
  }

  /// 按地区筛选食谱
  /// 示例: filterByArea("Canadian")
  Future<List<Meal>> filterByArea(String area) async {
    try {
      final response = await _dio.get('/filter.php', queryParameters: {'a': area});
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by area: $e');
      return [];
    }
  }

  /// 获取所有分类列表
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories.php');
      final categories = response.data['categories'] as List?;
      if (categories == null) return [];
      return categories.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// 获取所有地区列表
  Future<List<String>> getAreas() async {
    try {
      final response = await _dio.get('/list.php', queryParameters: {'a': 'list'});
      final meals = response.data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => m['strArea'] as String).toList();
    } catch (e) {
      debugPrint('Error getting areas: $e');
      return [];
    }
  }

  /// 获取所有食材列表
  Future<List<MealDbIngredient>> getIngredients() async {
    try {
      final response = await _dio.get('/list.php', queryParameters: {'i': 'list'});
      final meals = response.data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((json) => MealDbIngredient.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting ingredients: $e');
      return [];
    }
  }

  /// 获取一批随机食谱（用于首页展示）
  Future<List<Meal>> getRandomMeals(int count) async {
    final List<Meal> meals = [];
    for (int i = 0; i < count; i++) {
      final meal = await getRandomMeal();
      if (meal != null) {
        meals.add(meal);
      }
    }
    return meals;
  }

  /// 解析API返回的meals数据
  List<Meal> _parseMeals(Map<String, dynamic> data) {
    final meals = data['meals'] as List?;
    if (meals == null) return [];
    return meals.map((json) => Meal.fromJson(json)).toList();
  }
}

/// TheMealDB 食谱模型
class Meal {
  final String id;
  final String name;
  final String? alternateName;
  final String category;
  final String area;
  final String instructions;
  final String? thumbnail;
  final String? tags;
  final String? youtubeUrl;
  final List<MealIngredient> ingredients;
  final String? source;

  Meal({
    required this.id,
    required this.name,
    this.alternateName,
    required this.category,
    required this.area,
    required this.instructions,
    this.thumbnail,
    this.tags,
    this.youtubeUrl,
    required this.ingredients,
    this.source,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // 解析食材（API返回的是 ingredient1-20 和 measure1-20）
    final List<MealIngredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(MealIngredient(
          name: ingredient.trim(),
          measure: measure?.trim() ?? '',
        ));
      }
    }

    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal'] ?? '',
      alternateName: json['strMealAlternate'],
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'],
      tags: json['strTags'],
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      source: json['strSource'],
    );
  }

  /// 获取标签列表
  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((t) => t.trim()).toList();
  }

  /// 获取烹饪时间（API不返回，随机生成一个合理的）
  String get estimatedTime {
    // 根据食材数量估算时间
    if (ingredients.length <= 5) return '15';
    if (ingredients.length <= 10) return '30';
    return '45';
  }

  /// 获取卡路里（API不返回，随机生成一个合理的）
  String get estimatedCalories {
    // 简单估算：基于食材数量
    final base = 200 + (ingredients.length * 50);
    return base.toString();
  }

  /// 获取简短的描述（取instructions的前两句）
  String get shortDescription {
    final sentences = instructions.split(RegExp(r'[.!?]\s+'));
    if (sentences.isEmpty) return '';
    final desc = sentences.take(2).join('. ');
    return desc.length > 100 ? '${desc.substring(0, 100)}...' : desc;
  }
}

/// 食材项
class MealIngredient {
  final String name;
  final String measure;

  MealIngredient({
    required this.name,
    required this.measure,
  });
}

/// 分类模型
class Category {
  final String id;
  final String name;
  final String description;
  final String? thumbnail;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.thumbnail,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory']?.toString() ?? '',
      name: json['strCategory'] ?? '',
      description: json['strCategoryDescription'] ?? '',
      thumbnail: json['strCategoryThumb'],
    );
  }
}

/// 食材模型 (来自TheMealDB)
class MealDbIngredient {
  final String id;
  final String name;
  final String? description;

  MealDbIngredient({
    required this.id,
    required this.name,
    this.description,
  });

  factory MealDbIngredient.fromJson(Map<String, dynamic> json) {
    return MealDbIngredient(
      id: json['idIngredient']?.toString() ?? '',
      name: json['strIngredient'] ?? '',
      description: json['strDescription'],
    );
  }
}
