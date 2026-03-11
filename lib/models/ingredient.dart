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
        {'text': '识别这些图片中的所有食材。'}
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
                        '你是一个专业的厨房助手。请识别图片中的食材，并以JSON格式返回。结构必须为: {"ingredients": [{"name": "食材名", "amount": "数量/重量", "category": "分类"}]}。分类仅限: 蔬菜类, 肉类, 蛋奶类, 水果类, 调料, 其他。只返回JSON，不要有其他解释。'
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
    final timePref = prefs['time'] ?? '不限';
    final flavorPref = prefs['flavor'] ?? '清淡';
    final equipmentPref = prefs['equipment'] ?? '不限';

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
                    '你是一个专业的厨师。请根据用户提供的食材和偏好生成一个详细的食谱。必须以JSON格式返回，结构如下：{"title": "食谱名称", "description": "简短描述", "time": "预计时间(分钟)", "calories": "预计热量(kcal)", "tags": ["标签1", "标签2"], "ingredients": [{"name": "食材名", "amount": "数量"}], "steps": ["步骤1", "步骤2"]}。如果提供的食材太少、不合理或无法组合成任何食谱，请务必返回以下JSON：{"error": "理由", "suggestion": "给用户的建议"}。只返回JSON，不要有其他解释文字。'
              },
              {
                'role': 'user',
                'content':
                    '食材：$ingredientsList。偏好：烹饪时间 $timePref，口味 $flavorPref，厨具 $equipmentPref。'
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
            message: result['error'] ?? '无法生成食谱',
            suggestion: result['suggestion'] ?? '请尝试添加更多食材',
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
