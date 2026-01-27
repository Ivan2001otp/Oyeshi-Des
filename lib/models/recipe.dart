import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack }

enum DietaryRestriction { 
  vegetarian, 
  vegan, 
  glutenFree, 
  dairyFree, 
  nutFree, 
  lowCarb, 
  lowSodium 
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final MealType mealType;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<String> dietaryTags;
  final String imageUrl;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.mealType,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.dietaryTags,
    required this.imageUrl,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    MealType? mealType,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    List<String>? dietaryTags,
    String? imageUrl,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      mealType: mealType ?? this.mealType,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'mealType': mealType.name,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'dietaryTags': dietaryTags,
      'imageUrl': imageUrl,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      ingredients: List<String>.from(map['ingredients'] as List),
      instructions: List<String>.from(map['instructions'] as List),
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
        orElse: () => MealType.dinner,
      ),
      prepTimeMinutes: map['prepTimeMinutes'] as int,
      cookTimeMinutes: map['cookTimeMinutes'] as int,
      servings: map['servings'] as int,
      dietaryTags: List<String>.from(map['dietaryTags'] as List),
      imageUrl: map['imageUrl'] as String,
      rating: (map['rating'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Recipe.fromMap({...map, 'id': doc.id});
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description);
  }
}