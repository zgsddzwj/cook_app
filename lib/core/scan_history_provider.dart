import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/ingredient.dart';
import '../models/recipe.dart';

class ScanHistoryEntry {
  final String id;
  final String imagePath;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final Uint8List thumbnailBytes;
  final Recipe? linkedRecipe;

  const ScanHistoryEntry({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    required this.ingredients,
    required this.thumbnailBytes,
    this.linkedRecipe,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'thumbnailBytes': base64Encode(thumbnailBytes),
      'linkedRecipe': linkedRecipe?.toJson(),
    };
  }

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ScanHistoryEntry(
      id: json['id'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      thumbnailBytes: base64Decode(json['thumbnailBytes']),
      linkedRecipe: json['linkedRecipe'] != null
          ? Recipe.fromJson(json['linkedRecipe'])
          : null,
    );
  }
}

class ScanHistoryProvider extends ChangeNotifier {
  final List<ScanHistoryEntry> _entries = [];
  static const String _storageKey = 'scan_history';

  ScanHistoryProvider() {
    _loadHistory();
  }

  List<ScanHistoryEntry> get entries =>
      List<ScanHistoryEntry>.unmodifiable(_entries);

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_storageKey);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _entries.clear();
        _entries.addAll(decoded.map((item) => ScanHistoryEntry.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading scan history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving scan history: $e');
    }
  }

  /// Clear all scan history entries
  Future<void> clearHistory() async {
    _entries.clear();
    await _saveHistory();
    notifyListeners();
  }

  void addEntry({
    required String imagePath,
    required Uint8List thumbnailBytes,
    required List<Ingredient> ingredients,
    Recipe? linkedRecipe,
  }) {
    _entries.insert(
      0,
      ScanHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        createdAt: DateTime.now(),
        ingredients: List<Ingredient>.from(ingredients),
        thumbnailBytes: thumbnailBytes,
        linkedRecipe: linkedRecipe,
      ),
    );
    _saveHistory();
    notifyListeners();
  }

  void addEntryWithId({
    required String id,
    required String imagePath,
    required Uint8List thumbnailBytes,
    required List<Ingredient> ingredients,
    Recipe? linkedRecipe,
  }) {
    _entries.insert(
      0,
      ScanHistoryEntry(
        id: id,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        ingredients: List<Ingredient>.from(ingredients),
        thumbnailBytes: thumbnailBytes,
        linkedRecipe: linkedRecipe,
      ),
    );
    _saveHistory();
    notifyListeners();
  }

  void updateEntryRecipe(String entryId, Recipe recipe) {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      _entries[index] = ScanHistoryEntry(
        id: _entries[index].id,
        imagePath: _entries[index].imagePath,
        createdAt: _entries[index].createdAt,
        ingredients: _entries[index].ingredients,
        thumbnailBytes: _entries[index].thumbnailBytes,
        linkedRecipe: recipe,
      );
      _saveHistory();
      notifyListeners();
    }
  }

  void removeById(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveHistory();
    notifyListeners();
  }
}
