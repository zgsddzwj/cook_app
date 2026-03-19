import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';
import 'local_ml_service.dart';

/// Recognition mode
enum RecognitionMode {
  local, // Local TFLite model (offline)
  cloud, // Cloud AI service (online)
  auto, // Try local first, fallback to cloud
}

/// Unified recognition service
/// Handles switching between local ML and cloud AI
class RecognitionService {
  static const String _prefsKey = 'recognition_mode';
  static RecognitionMode _mode = RecognitionMode.cloud;

  /// Cloud service callback - set this in main.dart
  static Future<List<Ingredient>> Function(List<String>)? cloudRecognizer;

  /// Initialize service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _mode = RecognitionMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => RecognitionMode.cloud,
      );
    }

    // Pre-init local model if needed
    if (_mode == RecognitionMode.local || _mode == RecognitionMode.auto) {
      try {
        await LocalMLService.initialize();
      } catch (e) {
        debugPrint('Local ML init failed: $e');
      }
    }
  }

  /// Get current mode
  static RecognitionMode get mode => _mode;

  /// Set mode
  static Future<void> setMode(RecognitionMode mode) async {
    debugPrint('Switching recognition mode to: ${mode.name}');
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);

    if ((mode == RecognitionMode.local || mode == RecognitionMode.auto) &&
        !LocalMLService.isReady) {
      await LocalMLService.initialize();
    }
  }

  /// Recognize ingredients
  static Future<List<Ingredient>> recognize(List<String> imagePaths) async {
    switch (_mode) {
      case RecognitionMode.local:
        return await _recognizeLocal(imagePaths);

      case RecognitionMode.cloud:
        return await _recognizeCloud(imagePaths);

      case RecognitionMode.auto:
        return await _recognizeAuto(imagePaths);
    }
  }

  static Future<List<Ingredient>> _recognizeLocal(List<String> paths) async {
    if (!LocalMLService.isReady) {
      await LocalMLService.initialize();
    }
    return await LocalMLService.recognizeIngredients(paths);
  }

  static Future<List<Ingredient>> _recognizeCloud(List<String> paths) async {
    if (cloudRecognizer == null) {
      throw Exception('Cloud recognizer not configured');
    }
    return await cloudRecognizer!(paths);
  }

  static Future<List<Ingredient>> _recognizeAuto(List<String> paths) async {
    // Try local first
    try {
      if (LocalMLService.isReady) {
        final results = await LocalMLService.recognizeIngredients(paths);
        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      debugPrint('Local failed, using cloud: $e');
    }

    // Fallback to cloud
    return await _recognizeCloud(paths);
  }

  /// Check if local model is available
  static bool get isLocalAvailable => LocalMLService.isReady;

  /// Check if cloud is configured
  static bool get isCloudConfigured => cloudRecognizer != null;
}
