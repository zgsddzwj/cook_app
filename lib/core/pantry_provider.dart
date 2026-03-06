import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class PantryProvider extends ChangeNotifier {
  final List<Ingredient> _ingredients = [
    Ingredient(name: '全脂牛奶', amount: '1 L', category: '蛋奶类'),
    Ingredient(name: '有机菠菜', amount: '300 g', category: '蔬菜类'),
    Ingredient(name: '草饲牛排', amount: '2 块', category: '肉类'),
    Ingredient(name: '鸡蛋', amount: '12 个', category: '蛋奶类'),
    Ingredient(name: '红苹果', amount: '5 个', category: '水果类'),
  ];

  List<Ingredient> get ingredients => _ingredients;

  void addIngredients(List<Ingredient> newIngredients) {
    print('Adding ${newIngredients.length} ingredients to pantry');
    _ingredients.addAll(newIngredients);
    notifyListeners();
  }

  void removeIngredient(int index) {
    _ingredients.removeAt(index);
    notifyListeners();
  }
}
