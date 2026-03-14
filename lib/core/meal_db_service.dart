import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';

/// TheMealDB API Service with caching
/// 文档: https://www.themealdb.com/api.php
class MealDbService {
  static final MealDbService _instance = MealDbService._internal();
  factory MealDbService() => _instance;
  MealDbService._internal() {
    _initCache();
  }

  late final Dio _dio;
  late final CacheStore _cacheStore;
  late final DioCacheInterceptor _cacheInterceptor;
  bool _initialized = false;

  Future<void> _initCache() async {
    if (_initialized) return;
    
    // Initialize cache store
    _cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    
    final cacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
      cipher: null,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );
    
    _cacheInterceptor = DioCacheInterceptor(options: cacheOptions);
    
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://www.themealdb.com/api/json/v1/1',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    
    _dio.interceptors.add(_cacheInterceptor);
    _initialized = true;
  }

  /// 按名称搜索食谱
  Future<List<Meal>> searchMeals(String query) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/search.php',
        queryParameters: {'s': query},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error searching meals: $e');
      return [];
    }
  }

  /// 按首字母列出食谱
  Future<List<Meal>> listMealsByFirstLetter(String letter) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/search.php',
        queryParameters: {'f': letter},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error listing meals: $e');
      return [];
    }
  }

  /// 通过ID获取食谱详情
  Future<Meal?> getMealById(String id) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/lookup.php',
        queryParameters: {'i': id},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      final meals = _parseMeals(response.data);
      return meals.isNotEmpty ? meals.first : null;
    } catch (e) {
      debugPrint('Error getting meal by id: $e');
      return null;
    }
  }

  /// 获取随机食谱
  Future<Meal?> getRandomMeal() async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/random.php',
        options: Options(extra: {'cachePolicy': CachePolicy.noCache}), // Don't cache random
      );
      final meals = _parseMeals(response.data);
      return meals.isNotEmpty ? meals.first : null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint('Random meal request timeout');
      } else {
        debugPrint('Error getting random meal: $e');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting random meal: $e');
      return null;
    }
  }

  /// 按食材筛选食谱
  Future<List<Meal>> filterByIngredient(String ingredient) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/filter.php',
        queryParameters: {'i': ingredient},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by ingredient: $e');
      return [];
    }
  }

  /// 按分类筛选食谱
  Future<List<Meal>> filterByCategory(String category) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/filter.php',
        queryParameters: {'c': category},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by category: $e');
      return [];
    }
  }

  /// 按地区筛选食谱
  Future<List<Meal>> filterByArea(String area) async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/filter.php',
        queryParameters: {'a': area},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      return _parseMeals(response.data);
    } catch (e) {
      debugPrint('Error filtering by area: $e');
      return [];
    }
  }

  /// 获取所有分类列表
  Future<List<Category>> getCategories() async {
    await _initCache();
    try {
      final response = await _dio.get(
        '/categories.php',
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
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
    await _initCache();
    try {
      final response = await _dio.get(
        '/list.php',
        queryParameters: {'a': 'list'},
        options: Options(extra: {'cachePolicy': CachePolicy.forceCache}),
      );
      final meals = response.data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => m['strArea'] as String).toList();
    } catch (e) {
      debugPrint('Error getting areas: $e');
      return [];
    }
  }

  /// 获取一批随机食谱
  Future<List<Meal>> getRandomMeals(int count) async {
    final List<Meal> meals = [];
    
    for (int i = 0; i < count; i += 3) {
      final batchSize = (count - i).clamp(0, 3);
      final futures = List.generate(batchSize, (_) => getRandomMeal());
      
      try {
        final results = await Future.wait(futures, eagerError: false);
        meals.addAll(results.whereType<Meal>());
      } catch (e) {
        debugPrint('Error in random meals batch: $e');
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

  /// Clear API cache
  Future<void> clearCache() async {
    await _cacheStore.clean();
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

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((t) => t.trim()).toList();
  }

  String get estimatedTime {
    if (ingredients.length <= 5) return '15';
    if (ingredients.length <= 10) return '30';
    return '45';
  }

  String get estimatedCalories {
    final base = 200 + (ingredients.length * 50);
    return base.toString();
  }

  String get shortDescription {
    final sentences = instructions.split(RegExp(r'[.!?]\s+'));
    if (sentences.isEmpty) return '';
    final desc = sentences.take(2).join('. ');
    return desc.length > 100 ? '${desc.substring(0, 100)}...' : desc;
  }
}

class MealIngredient {
  final String name;
  final String measure;

  MealIngredient({
    required this.name,
    required this.measure,
  });
}

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
