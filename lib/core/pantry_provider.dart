import 'package:flutter/material.dart';
import '../models/ingredient.dart';

enum PantrySortType {
  category,
  expiryDate,
  quantity,
}

class PantryProvider extends ChangeNotifier {
  final List<Ingredient> _ingredients = [
    Ingredient(
      name: '全脂牛奶',
      amount: '1 L',
      category: '蛋奶类',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      quantity: 1.0,
    ),
    Ingredient(
      name: '有机菠菜',
      amount: '300 g',
      category: '蔬菜类',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      quantity: 300.0,
    ),
    Ingredient(
      name: '草饲牛排',
      amount: '2 块',
      category: '肉类',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      quantity: 2.0,
    ),
    Ingredient(
      name: '鸡蛋',
      amount: '12 个',
      category: '蛋奶类',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      quantity: 12.0,
    ),
    Ingredient(
      name: '红苹果',
      amount: '5 个',
      category: '水果类',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      quantity: 5.0,
    ),
  ];

  PantrySortType _currentSortType = PantrySortType.expiryDate;

  PantrySortType get currentSortType => _currentSortType;

  List<Ingredient> get ingredients {
    final sortedList = List<Ingredient>.from(_ingredients);
    switch (_currentSortType) {
      case PantrySortType.category:
        sortedList.sort((a, b) => a.category.compareTo(b.category));
        break;
      case PantrySortType.expiryDate:
        sortedList.sort((a, b) {
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case PantrySortType.quantity:
        sortedList.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }
    return sortedList;
  }

  void setSortType(PantrySortType type) {
    _currentSortType = type;
    notifyListeners();
  }

  void addIngredients(List<Ingredient> newIngredients) {
    print('Adding ${newIngredients.length} ingredients to pantry');
    _ingredients.addAll(newIngredients);
    notifyListeners();
  }

  void removeIngredient(Ingredient item) {
    _ingredients.removeWhere((element) => element.name == item.name && element.expiryDate == item.expiryDate);
    notifyListeners();
  }
}
