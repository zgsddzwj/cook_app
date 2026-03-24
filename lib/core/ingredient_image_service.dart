import '../models/ingredient.dart';

/// Ingredient image service using Unsplash high-quality photos
/// This service provides relevant imagery for ingredients and categories
class IngredientImageService {
  /// Map of ingredient keywords to Unsplash image URLs
  static const Map<String, String> _ingredientImages = {
    // Dairy
    'milk': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&fit=crop',
    'whole milk': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&fit=crop',
    'cheese': 'https://images.unsplash.com/photo-1486297678742-1b60db7f6b8d?w=400&fit=crop',
    'butter': 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&fit=crop',
    'cream': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&fit=crop',
    'yogurt': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&fit=crop',
    'egg': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&fit=crop',
    'eggs': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&fit=crop',
    
    // Meat
    'beef': 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=400&fit=crop',
    'steak': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&fit=crop',
    'chicken': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&fit=crop',
    'pork': 'https://images.unsplash.com/photo-1607623814075-e51df1bd656e?w=400&fit=crop',
    'lamb': 'https://images.unsplash.com/photo-1603360946369-dc9bb6f54262?w=400&fit=crop',
    'fish': 'https://images.unsplash.com/photo-1615141982880-1313d06a7fb3?w=400&fit=crop',
    'salmon': 'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=400&fit=crop',
    'shrimp': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&fit=crop',
    
    // Vegetables
    'spinach': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&fit=crop',
    'lettuce': 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&fit=crop',
    'tomato': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&fit=crop',
    'carrot': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&fit=crop',
    'onion': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&fit=crop',
    'potato': 'https://images.unsplash.com/photo-1518977676601-b53f82berb0a?w=400&fit=crop',
    'potatoes': 'https://images.unsplash.com/photo-1518977676601-b53f82b40c01?w=400&fit=crop',
    'broccoli': 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&fit=crop',
    'cucumber': 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=400&fit=crop',
    'pepper': 'https://images.unsplash.com/photo-1563565375-f3fdf5ce4e2a?w=400&fit=crop',
    'mushroom': 'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=400&fit=crop',
    'mushrooms': 'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=400&fit=crop',
    'cabbage': 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=400&fit=crop',
    'cauliflower': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&fit=crop',
    'eggplant': 'https://images.unsplash.com/photo-1613881554723-5e8e352c41f2?w=400&fit=crop',
    'garlic': 'https://images.unsplash.com/photo-1615470202678-e18d80ea66f7?w=400&fit=crop',
    
    // Fruits
    'apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&fit=crop',
    'apples': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&fit=crop',
    'banana': 'https://images.unsplash.com/photo-1571771896612-618b42e166de?w=400&fit=crop',
    'orange': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&fit=crop',
    'lemon': 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400&fit=crop',
    'strawberry': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&fit=crop',
    'blueberry': 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&fit=crop',
    'avocado': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&fit=crop',
    
    // Grains & Others
    'bread': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&fit=crop',
    'rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&fit=crop',
    'pasta': 'https://images.unsplash.com/photo-1551183053-bf91b1d3116c?w=400&fit=crop',
    'flour': 'https://images.unsplash.com/photo-1627485937980-221c88ac04f9?w=400&fit=crop',
    'oil': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
    'olive oil': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
    'sugar': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&fit=crop',
    'salt': 'https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=400&fit=crop',
    'honey': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&fit=crop',
    'tofu': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop',
  };

  /// Category background images for detail page
  static const Map<String, String> _categoryImages = {
    'Vegetables': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&fit=crop',
    'Meat': 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=800&fit=crop',
    'Dairy': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=800&fit=crop',
    'Fruits': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&fit=crop',
    'Seasoning': 'https://images.unsplash.com/photo-1532336414038-cf19250c5757?w=800&fit=crop',
    'Other': 'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=800&fit=crop',
  };

  /// Get ingredient thumbnail image URL for list view
  static String getIngredientThumbnail(Ingredient ingredient) {
    final name = ingredient.name.trim().toLowerCase();
    
    // Try exact match first
    if (_ingredientImages.containsKey(name)) {
      return _ingredientImages[name]!;
    }
    
    // Try partial match
    for (final entry in _ingredientImages.entries) {
      if (name.contains(entry.key) || entry.key.contains(name)) {
        return entry.value;
      }
    }
    
    // Fall back to category image
    return getCategoryImage(ingredient.category);
  }

  /// Get large background image for detail page
  static String getIngredientDetailImage(Ingredient ingredient) {
    // Try to find a more specific image for the ingredient
    final thumbnailUrl = getIngredientThumbnail(ingredient);
    
    // If it's a category fallback, try to get a better one
    if (thumbnailUrl.contains('category_')) {
      return getCategoryImage(ingredient.category).replaceAll('w=400', 'w=800');
    }
    
    // Return higher resolution version
    return thumbnailUrl.replaceAll('w=400', 'w=800');
  }

  /// Get category background image
  static String getCategoryImage(String category) {
    return _categoryImages[category] ?? _categoryImages['Other']!;
  }
}
