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
      name: 'Whole Milk',
      amount: '1 L',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      quantity: 1.0,
    ),
    Ingredient(
      name: 'Organic Spinach',
      amount: '300 g',
      category: 'Vegetables',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      quantity: 300.0,
    ),
    Ingredient(
      name: 'Grass-fed Steak',
      amount: '2 pcs',
      category: 'Meat',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      quantity: 2.0,
    ),
    Ingredient(
      name: 'Eggs',
      amount: '12 pcs',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      quantity: 12.0,
    ),
    Ingredient(
      name: 'Red Apples',
      amount: '5 pcs',
      category: 'Fruits',
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
