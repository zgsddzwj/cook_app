import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/ingredient.dart';

/// Local ML Service using TensorFlow Lite
/// Runs entirely on device - no internet required
/// Uses MobileNet V3 model for image classification
class LocalMLService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _isInitialized = false;

  /// Initialize the model
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model from assets
      _interpreter =
          await Interpreter.fromAsset('assets/models/mobilenet_v3.tflite');

      // Load labels
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n');

      _isInitialized = true;
      debugPrint('Local ML Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Local ML Service: $e');
      rethrow;
    }
  }

  /// Check if service is ready
  static bool get isReady => _isInitialized && _interpreter != null;

  /// Recognize ingredients from local images
  static Future<List<Ingredient>> recognizeIngredients(
      List<String> imagePaths) async {
    if (!isReady) {
      await initialize();
    }

    final Set<String> detectedIngredients = {};
    final List<Ingredient> results = [];

    for (String imagePath in imagePaths) {
      try {
        final detections = await _classifyImage(imagePath);
        for (final detection in detections) {
          if (!detectedIngredients.contains(detection)) {
            detectedIngredients.add(detection);
            results.add(_createIngredient(detection));
          }
        }
      } catch (e) {
        debugPrint('Error classifying image: $e');
      }
    }

    return results;
  }

  /// Classify a single image
  static Future<List<String>> _classifyImage(String imagePath) async {
    if (_interpreter == null) throw Exception('Model not initialized');

    // Load and preprocess image
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Failed to decode image');

    // Resize to 224x224 (MobileNet input size)
    final img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Normalize and create input buffer
    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // Run inference
    var output = List.generate(1, (i) => List<double>.filled(1000, 0));
    _interpreter!.run(input, output);

    // Get top 3 predictions
    final predictions = _getTopPredictions(output[0], topK: 3);

    return predictions.map((p) => p.label).toList();
  }

  /// Get top K predictions
  static List<Prediction> _getTopPredictions(List<double> scores,
      {int topK = 3}) {
    final List<Prediction> predictions = [];

    for (int i = 0; i < scores.length; i++) {
      predictions.add(Prediction(
        index: i,
        score: scores[i],
        label: _labels != null && i < _labels!.length ? _labels![i] : 'Unknown',
      ));
    }

    predictions.sort((a, b) => b.score.compareTo(a.score));
    return predictions.take(topK).toList();
  }

  /// Create Ingredient from detected label
  static Ingredient _createIngredient(String label) {
    // Map ML labels to ingredient categories
    final String lowerLabel = label.toLowerCase();

    String category = 'Other';
    if (_vegetables.any((v) => lowerLabel.contains(v))) {
      category = 'Vegetables';
    } else if (_fruits.any((f) => lowerLabel.contains(f))) {
      category = 'Fruits';
    } else if (_meats.any((m) => lowerLabel.contains(m))) {
      category = 'Meat';
    } else if (_dairy.any((d) => lowerLabel.contains(d))) {
      category = 'Dairy';
    }

    return Ingredient(
      name: label.replaceAll('_', ' ').capitalize(),
      amount: 'Unknown',
      category: category,
    );
  }

  /// Release resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }

  // Common food keywords for category mapping
  static const List<String> _vegetables = [
    'carrot',
    'broccoli',
    'lettuce',
    'tomato',
    'potato',
    'onion',
    'garlic',
    'spinach',
    'cucumber',
    'pepper',
    'cabbage',
    'cauliflower',
    'celery',
    'eggplant',
    'zucchini',
    'asparagus',
    'mushroom',
    'corn',
    'pea',
    'bean'
  ];

  static const List<String> _fruits = [
    'apple',
    'banana',
    'orange',
    'lemon',
    'lime',
    'grape',
    'strawberry',
    'blueberry',
    'raspberry',
    'watermelon',
    'pineapple',
    'mango',
    'peach',
    'pear',
    'cherry',
    'kiwi',
    'melon',
    'coconut'
  ];

  static const List<String> _meats = [
    'beef',
    'chicken',
    'pork',
    'lamb',
    'steak',
    'meat',
    'sausage',
    'bacon',
    'ham',
    'turkey',
    'duck',
    'fish',
    'salmon',
    'tuna',
    'shrimp',
    'prawn',
    'crab',
    'lobster'
  ];

  static const List<String> _dairy = [
    'cheese',
    'milk',
    'butter',
    'cream',
    'yogurt',
    'egg'
  ];
}

class Prediction {
  final int index;
  final double score;
  final String label;

  Prediction({required this.index, required this.score, required this.label});
}

/// String extension for capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// ML Model download helper
/// Downloads model from server on first launch
class MLModelDownloader {
  static const String _modelVersionKey = 'ml_model_version';

  /// Check if model needs download/update
  static Future<bool> needsUpdate() async {
    // TODO: Check with server for model updates
    return false;
  }

  /// Download model from server
  static Future<void> downloadModel() async {
    // TODO: Implement model download
    // This is for future enhancement - download newer/better models
  }
}
