import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

class Ingredient {
  final String name;
  final String amount;
  final String category;
  final DateTime? expiryDate;
  final double quantity; // Numeric quantity for sorting

  Ingredient({
    required this.name,
    required this.amount,
    required this.category,
    this.expiryDate,
    this.quantity = 1.0,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    // Try to parse numeric quantity from amount string if possible
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

class LLMService {
  static final Dio _dio = Dio();

  // Calling Alibaba Cloud (DashScope) API with Qwen-VL-Plus (Vision model)
  static Future<List<Ingredient>> recognizeIngredients(
      List<String> imagePaths) async {
    final apiKey = dotenv.env['ALIBABA_CLOUD_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alibaba Cloud API Key not found in .env file');
    }

    try {
      final List<Map<String, dynamic>> contentItems = [
        {'text': 'Identify all ingredients in these images. Return in English only.'}
      ];

      for (String imagePath in imagePaths) {
        final File imageFile = File(imagePath);
        final List<int> imageBytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(imageBytes);
        contentItems.insert(0, {'image': 'data:image/png;base64,$base64Image'});
      }

      final response = await _dio.post(
        'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'qwen-vl-plus',
          'input': {
            'messages': [
              {
                'role': 'system',
                'content': [
                  {
                    'text':
                        'You are a professional kitchen assistant. Identify ingredients in the images and return in JSON format. Structure must be: {"ingredients": [{"name": "ingredient name in English", "amount": "quantity/weight", "category": "category"}]}. Categories allowed: Vegetables, Meat, Dairy, Fruits, Seasoning, Other. Return JSON only, no explanation.'
                  }
                ]
              },
              {'role': 'user', 'content': contentItems}
            ]
          },
          'parameters': {'result_format': 'message'}
        },
      );

      if (response.statusCode == 200) {
        // print('API Response: ${response.data}'); // Debug logging
        final String content = response.data['output']['choices'][0]['message']
            ['content'][0]['text'];
        print('Raw content from LLM: $content');

        // Extract JSON from potential markdown blocks
        String jsonStr = content;
        if (content.contains('```json')) {
          jsonStr = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          jsonStr = content.split('```')[1].split('```')[0].trim();
        }

        // Clean up any potential leading/trailing non-JSON characters
        final jsonStart = jsonStr.indexOf('{');
        final jsonEnd = jsonStr.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
        }

        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final List<dynamic> ingredientsJson = decoded['ingredients'] ?? [];

        return ingredientsJson.map((j) => Ingredient.fromJson(j)).toList();
      } else {
        throw Exception(
            'Failed to call Alibaba API: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Error recognizing ingredients: $e');
      rethrow; // Rethrow to let the UI handle the error
    }
  }

  // Generate recipe based on ingredients and preferences
  static Future<Map<String, dynamic>> generateRecipe(
      List<Ingredient> ingredients, Map<String, dynamic> prefs) async {
    final apiKey = dotenv.env['ALIBABA_CLOUD_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alibaba Cloud API Key not found in .env file');
    }

    final ingredientsList = ingredients.map((i) => i.name).join(', ');
    final timePref = prefs['time'] ?? 'Any';
    final flavorPref = prefs['flavor'] ?? 'Light';
    final equipmentPref = prefs['equipment'] ?? 'Any';

    try {
      final response = await _dio.post(
        'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'qwen-max',
          'input': {
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are a professional chef. Generate recipes based on provided ingredients and preferences. Guidelines: 1. Do not force using all ingredients in one dish - prioritize pairing logic and taste. 2. If ingredients are abundant, generate multiple dishes (main + side) in a "recipes" array. 3. If few ingredients, create one quality dish. Must return JSON format: {"recipes": [{"title": "Recipe Name in English", "description": "Brief description in English", "time": "Estimated time (minutes)", "calories": "Estimated calories (kcal)", "tags": ["Tag1", "Tag2"], "ingredients": [{"name": "Ingredient name in English", "amount": "Quantity"}], "steps": ["Step 1 in English", "Step 2 in English"]}]}. If ingredients are too few or cannot form a reasonable dish, return: {"error": "Reason in English", "suggestion": "Suggestion in English"}. Return JSON only, no explanation. ALL CONTENT MUST BE IN ENGLISH.'
              },
              {
                'role': 'user',
                'content':
                    'Ingredients: $ingredientsList. Preferences: Cooking time $timePref, Flavor $flavorPref, Equipment $equipmentPref.'
              }
            ]
          },
          'parameters': {'result_format': 'message'}
        },
      );

      if (response.statusCode == 200) {
        final String content =
            response.data['output']['choices'][0]['message']['content'];
        print('Raw content from LLM (Recipe): $content');

        String jsonStr = content;
        if (content.contains('```json')) {
          jsonStr = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          jsonStr = content.split('```')[1].split('```')[0].trim();
        }

        final jsonStart = jsonStr.indexOf('{');
        final jsonEnd = jsonStr.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
        }

        final Map<String, dynamic> result = jsonDecode(jsonStr);

        // 检查是否有错误信息
        if (result.containsKey('error')) {
          throw RecipeGenerationException(
            message: result['error'] ?? 'Failed to generate recipe',
            suggestion: result['suggestion'] ?? 'Please try adding more ingredients',
          );
        }

        return result;
      } else {
        throw Exception('Failed to call Alibaba API: ${response.statusCode}');
      }
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
