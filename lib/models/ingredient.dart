import '../core/api_service.dart';

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

/// LLM Service using our backend API
class LLMService {
  /// Recognize ingredients from images using our backend API
  static Future<List<Ingredient>> recognizeIngredients(
      List<String> imagePaths) async {
    return await ApiService().recognizeIngredients(imagePaths);
  }

  /// Generate recipe based on ingredients and preferences using our backend API
  static Future<Map<String, dynamic>> generateRecipe(
      List<Ingredient> ingredients, Map<String, dynamic> prefs) async {
    try {
      final recipes = await ApiService().generateRecipes(
        ingredients: ingredients,
        preferences: prefs,
      );

      return {
        'recipes': recipes.map((r) => r.toJson()).toList(),
      };
    } catch (e) {
      // Re-wrap to maintain compatibility with existing error handling
      if (e.toString().contains('error')) {
        throw RecipeGenerationException(
          message: 'Failed to generate recipe',
          suggestion: 'Please try adding more ingredients',
        );
      }
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
