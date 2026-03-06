import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

class Ingredient {
  final String name;
  final String amount;
  final String category;

  Ingredient({
    required this.name,
    required this.amount,
    required this.category,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class LLMService {
  static final Dio _dio = Dio();
  
  // Calling Alibaba Cloud (DashScope) API with Qwen-VL-Plus (Vision model)
  static Future<List<Ingredient>> recognizeIngredients(String imagePath) async {
    final apiKey = dotenv.env['ALIBABA_CLOUD_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alibaba Cloud API Key not found in .env file');
    }

    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

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
                  {'text': '你是一个专业的厨房助手。请识别图片中的食材，并以JSON格式返回。结构必须为: {"ingredients": [{"name": "食材名", "amount": "数量/重量", "category": "分类"}]}。分类仅限: 蔬菜类, 肉类, 蛋奶类, 水果类, 调料, 其他。只返回JSON，不要有其他解释。'}
                ]
              },
              {
                'role': 'user',
                'content': [
                  {'image': 'data:image/png;base64,$base64Image'},
                  {'text': '识别这张图片中的所有食材。'}
                ]
              }
            ]
          },
          'parameters': {
            'result_format': 'message'
          }
        },
      );

      if (response.statusCode == 200) {
        // print('API Response: ${response.data}'); // Debug logging
        final String content = response.data['output']['choices'][0]['message']['content'][0]['text'];
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
        throw Exception('Failed to call Alibaba API: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Error recognizing ingredients: $e');
      rethrow; // Rethrow to let the UI handle the error
    }
  }
}
