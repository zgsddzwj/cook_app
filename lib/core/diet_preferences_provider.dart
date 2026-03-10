import 'package:flutter/material.dart';

class DietPreferencesProvider extends ChangeNotifier {
  final Map<String, bool> _selected = {
    'keto': true,
    'vegan': true,
    'vegetarian': true,
    'gluten_free': true,
    'low_carb': true,
    'dairy_free': true,
  };

  bool isSelected(String key) => _selected[key] ?? false;

  Map<String, bool> get selectedMap => Map<String, bool>.from(_selected);

  void setSelected(String key, bool value) {
    if (_selected[key] == value) return;
    _selected[key] = value;
    notifyListeners();
  }
}

