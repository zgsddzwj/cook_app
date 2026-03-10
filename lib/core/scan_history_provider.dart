import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/ingredient.dart';

class ScanHistoryEntry {
  final String id;
  final String imagePath;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final Uint8List thumbnailBytes;

  const ScanHistoryEntry({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    required this.ingredients,
    required this.thumbnailBytes,
  });
}

class ScanHistoryProvider extends ChangeNotifier {
  final List<ScanHistoryEntry> _entries = [];

  List<ScanHistoryEntry> get entries => List<ScanHistoryEntry>.unmodifiable(_entries);

  void addEntry({
    required String imagePath,
    required Uint8List thumbnailBytes,
    required List<Ingredient> ingredients,
  }) {
    _entries.insert(
      0,
      ScanHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        createdAt: DateTime.now(),
        ingredients: List<Ingredient>.from(ingredients),
        thumbnailBytes: thumbnailBytes,
      ),
    );
    notifyListeners();
  }

  void removeById(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

