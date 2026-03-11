class Recipe {
  final String id;
  final String title;
  final String description;
  final String time;
  final String calories;
  final String imageUrl;
  final List<String> tags;
  final List<Map<String, String>> ingredients;
  final List<String> steps;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.calories,
    required this.imageUrl,
    required this.tags,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });

  Recipe copyWith({bool? isFavorite}) {
    return Recipe(
      id: id,
      title: title,
      description: description,
      time: time,
      calories: calories,
      imageUrl: imageUrl,
      tags: tags,
      ingredients: ingredients,
      steps: steps,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'calories': calories,
      'imageUrl': imageUrl,
      'tags': tags,
      'ingredients': ingredients,
      'steps': steps,
      'isFavorite': isFavorite,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      calories: json['calories'],
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags']),
      ingredients: (json['ingredients'] as List)
          .map((i) => Map<String, String>.from(i))
          .toList(),
      steps: List<String>.from(json['steps']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
