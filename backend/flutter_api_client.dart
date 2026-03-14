import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/ingredient.dart';

/// API Configuration
class ApiConfig {
  // Change this to your server IP/domain
  static const String baseUrl = 'http://43.167.203.244';  // Your Tencent server
  // static const String baseUrl = 'https://api.yourdomain.com';  // With domain
  
  static const String apiKey = 'your-api-key-here';  // Same as backend API_KEY
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// SnapCook API Client
/// Replace the LLMService in your Flutter app with this
class SnapCookApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// Recognize ingredients from images
  static Future<List<Ingredient>> recognizeIngredients(List<String> imagePaths) async {
    try {
      // Create multipart form data
      final formData = FormData();
      
      // Add API key
      formData.fields.add(MapEntry('api_key', ApiConfig.apiKey));
      
      // Add images
      for (String path in imagePaths) {
        final file = File(path);
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

      final response = await _dio.post(
        '/api/v1/ingredients/recognize',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final ingredients = data['ingredients'] as List;
        
        return ingredients.map((json) => Ingredient(
          name: json['name'] ?? '',
          amount: json['amount'] ?? 'Unknown',
          category: json['category'] ?? 'Other',
        )).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
      throw Exception('Recognition failed: $errorMsg');
    } catch (e) {
      throw Exception('Recognition failed: $e');
    }
  }

  /// Generate recipe from ingredients
  static Future<Map<String, dynamic>> generateRecipe(
    List<Ingredient> ingredients,
    Map<String, dynamic> prefs,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/recipes/generate',
        data: {
          'api_key': ApiConfig.apiKey,
          'ingredients': ingredients.map((i) => {
            'name': i.name,
            'amount': i.amount,
            'category': i.category,
          }).toList(),
          'preferences': {
            'time': prefs['time'] ?? 'Any',
            'flavor': prefs['flavor'] ?? 'Any',
            'equipment': prefs['equipment'] ?? 'Any',
            'servings': prefs['servings'] ?? 2,
          },
          'language': 'en',
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
      throw Exception('Recipe generation failed: $errorMsg');
    }
  }

  /// Check for app updates
  static Future<Map<String, dynamic>> checkVersion(
    String platform,
    String version,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v1/app/version',
        queryParameters: {
          'platform': platform,
          'version': version,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Version check failed: $e');
    }
  }

  /// Get popular recipes
  static Future<List<dynamic>> getPopularRecipes({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/v1/recipes/popular',
        queryParameters: {
          'api_key': ApiConfig.apiKey,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data']['recipes'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  /// Submit feedback
  static Future<void> submitFeedback(
    String recipeId,
    int rating, {
    String? comment,
    String? userId,
  }) async {
    try {
      await _dio.post(
        '/api/v1/recipes/$recipeId/feedback',
        data: {
          'api_key': ApiConfig.apiKey,
          'rating': rating,
          'comment': comment,
          'user_id': userId,
        },
      );
    } catch (e) {
      // Silently fail for analytics
      print('Feedback submission failed: $e');
    }
  }

  /// Track analytics event
  static Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
    String? userId,
    String? deviceId,
  }) async {
    try {
      await _dio.post(
        '/api/v1/analytics/events',
        data: {
          'api_key': ApiConfig.apiKey,
          'event_name': eventName,
          'user_id': userId,
          'device_id': deviceId,
          'timestamp': DateTime.now().toIso8601String(),
          'properties': properties ?? {},
        },
      );
    } catch (e) {
      // Silently fail for analytics
      print('Analytics tracking failed: $e');
    }
  }

  /// Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
}

/*
HOW TO USE:

1. Copy this file to your Flutter project: lib/core/api_client.dart

2. Update lib/models/ingredient.dart - LLMService to use this client:

class LLMService {
  static Future<List<Ingredient>> recognizeIngredients(List<String> imagePaths) async {
    return await SnapCookApiClient.recognizeIngredients(imagePaths);
  }
  
  static Future<Map<String, dynamic>> generateRecipe(
    List<Ingredient> ingredients,
    Map<String, dynamic> prefs,
  ) async {
    return await SnapCookApiClient.generateRecipe(ingredients, prefs);
  }
}

3. Update the API configuration:
   - Change baseUrl to your server IP/domain
   - Set the apiKey to match your backend

4. For app update check, replace app_update_service.dart with:
   final version = await SnapCookApiClient.checkVersion('ios', '1.0.0');
*/
