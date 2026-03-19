import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

/// Backend API Service for SnapCook
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  bool _initialized = false;

  ApiService._internal() {
    // Initializing the API service with default configuration
    _init();
  }

  void _init() {
    if (_initialized) return;

    final baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }

    _initialized = true;
  }

  String get _apiKey => dotenv.env['BACKEND_API_KEY'] ?? '';

  /// Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// Recognize ingredients from images
  Future<List<Ingredient>> recognizeIngredients(List<String> imagePaths) async {
    try {
      final List<MultipartFile> files = [];
      for (final path in imagePaths) {
        files.add(await MultipartFile.fromFile(path));
      }

      final formData = FormData.fromMap({
        'api_key': _apiKey,
        'images': files,
      });

      final response = await _dio.post(
        '/api/v1/ingredients/recognize',
        data: formData,
      );

      if (response.data['success'] == true) {
        final List<dynamic> ingredientsJson =
            response.data['data']['ingredients'];
        return ingredientsJson
            .map((json) => Ingredient.fromJson(json))
            .toList();
      } else {
        throw Exception(
            response.data['error']?['message'] ?? 'Recognition failed');
      }
    } catch (e) {
      debugPrint('Error recognizing ingredients: $e');
      rethrow;
    }
  }

  /// Generate recipes based on ingredients and preferences
  Future<List<Recipe>> generateRecipes({
    required List<Ingredient> ingredients,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/recipes/generate',
        data: {
          'api_key': _apiKey,
          'ingredients': ingredients
              .map((i) => {
                    'name': i.name,
                    'amount': i.amount,
                  })
              .toList(),
          'preferences': preferences,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> recipesJson = response.data['data']['recipes'];
        return recipesJson.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['error']?['message'] ?? 'Recipe generation failed');
      }
    } catch (e) {
      debugPrint('Error generating recipes: $e');
      rethrow;
    }
  }

  /// Get popular recipes
  Future<List<Recipe>> getPopularRecipes({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/v1/recipes/popular',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> recipesJson = response.data['data']['recipes'];
        // Backend returns RecipeListItem which is slightly different,
        // but we'll try to map it to our Recipe model for now.
        return recipesJson.map((json) {
          return Recipe(
            id: json['id'],
            title: json['title'],
            description: '', // RecipeListItem doesn't have description
            time: json['time'],
            calories: json['calories'],
            imageUrl: json['image_url'],
            tags: List<String>.from(json['tags']),
            ingredients: const <Map<String,
                String>>[], // RecipeListItem doesn't have ingredients
            steps: const <String>[], // RecipeListItem doesn't have steps
          );
        }).toList();
      } else {
        throw Exception(response.data['error']?['message'] ??
            'Failed to get popular recipes');
      }
    } catch (e) {
      debugPrint('Error getting popular recipes: $e');
      return [];
    }
  }

  /// Check for app version update
  Future<Map<String, dynamic>?> checkVersion(
      String platform, String version) async {
    try {
      final response = await _dio.get(
        '/api/v1/app/version',
        queryParameters: {
          'platform': platform,
          'version': version,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error checking version: $e');
    }
    return null;
  }

  /// Submit recipe feedback
  Future<bool> submitFeedback(String recipeId, int rating,
      {String? comment}) async {
    try {
      final response = await _dio.post(
        '/api/v1/recipes/$recipeId/feedback',
        data: {
          'api_key': _apiKey,
          'rating': rating,
          'comment': comment,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      return false;
    }
  }
}
