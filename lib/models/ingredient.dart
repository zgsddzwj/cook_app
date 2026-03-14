import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

class Ingredient {
  final String name;
  final String amount;
  final String category;
  final DateTime? expiryDate;
  final double quantity;

  Ingredient({
    required this.name,
    required this.amount,
    required this.category,
    this.expiryDate,
    this.quantity = 1.0,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    double parsedQuantity = 1.0;
    try {
      final amountStr = json['amount'] ?? '1';
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(amountStr);
      if (match != null) {
        parsedQuantity = double.parse(match.group(1)!);
      }
    } catch (_) {}

    return Ingredient(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      category: json['category'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      quantity: parsedQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
    };
  }
}

/// LLM Service using CloseAI API (OpenAI compatible)
/// CloseAI is an OpenAI API proxy with better availability in some regions
/// Get API key from: https://console.closeai-asia.com/
class LLMService {
  static final Dio _dio = Dio();
  
  // CloseAI API Configuration
  static const String _baseUrl = 'https://api.closeai-asia.com/v1';
  static String get _visionModel => dotenv.env['CLOSEAI_VISION_MODEL'] ?? 'gpt-4o-mini';
  static String get _textModel => dotenv.env['CLOSEAI_TEXT_MODEL'] ?? 'gpt-4o-mini';

  /// Recognize ingredients from images using CloseAI Vision API
  static Future<List<Ingredient>> recognizeIngredients(
      List<String> imagePaths) async {
    final apiKey = dotenv.env['CLOSEAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('CloseAI API Key not found in .env file. Please add CLOSEAI_API_KEY to your .env file. Get it from https://console.closeai-asia.com/');
    }

    try {
      // Build content array with images and text
      final List<Map<String, dynamic>> content = [];
      
      // Add images
      for (String imagePath in imagePaths) {
        final File imageFile = File(imagePath);
        final List<int> imageBytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(imageBytes);
        content.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
          },
        });
      }
      
      // Add text prompt
      content.add({
        'type': 'text',
        'text': 'Identify all ingredients in these images. Return the result as a JSON object with this exact structure: {"ingredients": [{"name": "ingredient name in English", "amount": "quantity with unit", "category": "category"}]}. Categories allowed: Vegetables, Meat, Dairy, Fruits, Seasoning, Other. Return ONLY the JSON, no markdown, no explanation.',
      });

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _visionModel,
          'messages': [
            {
              'role': 'user',
              'content': content,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        },
      );

      if (response.statusCode == 200) {
        final String content = response.data['choices'][0]['message']['content'];
        print('Raw content from CloseAI: $content');

        // Extract JSON from potential markdown blocks
        String jsonStr = content.trim();
        if (content.contains('```json')) {
          jsonStr = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          jsonStr = content.split('```')[1].split('```')[0].trim();
        }

        // Clean up any potential leading/trailing non-JSON characters
        final jsonStart = jsonStr.indexOf('{');
        final jsonEnd = jsonStr.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
        }

        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final List<dynamic> ingredientsJson = decoded['ingredients'] ?? [];

        return ingredientsJson.map((j) => Ingredient.fromJson(j)).toList();
      } else {
        throw Exception(
            'Failed to call CloseAI API: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
      print('CloseAI API Error: $errorMsg');
      throw Exception('CloseAI API Error: $errorMsg');
    } catch (e) {
      print('Error recognizing ingredients: $e');
      rethrow;
    }
  }

  /// Generate recipe based on ingredients and preferences using CloseAI
  static Future<Map<String, dynamic>> generateRecipe(
      List<Ingredient> ingredients, Map<String, dynamic> prefs) async {
    final apiKey = dotenv.env['CLOSEAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('CloseAI API Key not found in .env file. Please add CLOSEAI_API_KEY to your .env file.');
    }

    final ingredientsList = ingredients.map((i) => '${i.name}(${i.amount})').join(', ');
    final timePref = prefs['time'] ?? 'Any';
    final flavorPref = prefs['flavor'] ?? 'Light';
    final equipmentPref = prefs['equipment'] ?? 'Any';

    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _textModel,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a professional chef. Generate recipes based on provided ingredients and preferences.

Guidelines:
1. Do not force using all ingredients - prioritize taste and pairing logic
2. If ingredients are abundant, generate multiple dishes (main + side)
3. If few ingredients, create one quality dish

MUST return JSON in this exact format:
{
  "recipes": [{
    "title": "Recipe Name",
    "description": "Brief description",
    "time": "Estimated minutes",
    "calories": "Estimated kcal",
    "tags": ["Tag1", "Tag2"],
    "ingredients": [{"name": "ingredient", "amount": "quantity"}],
    "steps": ["Step 1", "Step 2"]
  }]
}

If ingredients cannot form a reasonable dish, return:
{"error": "Reason", "suggestion": "Suggestion"}

Return ONLY JSON, no markdown, no explanation. ALL CONTENT IN ENGLISH.'''
            },
            {
              'role': 'user',
              'content': 'Ingredients: $ingredientsList. Preferences: Time: $timePref, Flavor: $flavorPref, Equipment: $equipmentPref.'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      );

      if (response.statusCode == 200) {
        final String content = response.data['choices'][0]['message']['content'];
        print('Raw content from CloseAI (Recipe): $content');

        String jsonStr = content.trim();
        if (content.contains('```json')) {
          jsonStr = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          jsonStr = content.split('```')[1].split('```')[0].trim();
        }

        final jsonStart = jsonStr.indexOf('{');
        final jsonEnd = jsonStr.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
        }

        final Map<String, dynamic> result = jsonDecode(jsonStr);

        // Check for error message from LLM
        if (result.containsKey('error')) {
          throw RecipeGenerationException(
            message: result['error'] ?? 'Failed to generate recipe',
            suggestion: result['suggestion'] ?? 'Please try adding more ingredients',
          );
        }

        return result;
      } else {
        throw Exception('Failed to call CloseAI API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
      print('CloseAI API Error: $errorMsg');
      throw Exception('CloseAI API Error: $errorMsg');
    } on RecipeGenerationException {
      rethrow;
    } catch (e) {
      print('Error generating recipe: $e');
      rethrow;
    }
  }
}

class RecipeGenerationException implements Exception {
  final String message;
  final String suggestion;

  RecipeGenerationException({required this.message, required this.suggestion});

  @override
  String toString() => 'RecipeGenerationException: $message ($suggestion)';
}
