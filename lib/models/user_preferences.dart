import 'package:oyeshi_des/models/recipe.dart';

class UserPreferences {
  final String userId;
  final List<DietaryRestriction> dietaryRestrictions;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final Map<MealType, bool> mealTypePreferences;
  final int defaultServings;
  final int maxPrepTime;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferences({
    required this.userId,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.mealTypePreferences = const {
      MealType.breakfast: true,
      MealType.lunch: true,
      MealType.dinner: true,
      MealType.snack: false,
    },
    this.defaultServings = 2,
    this.maxPrepTime = 60,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  UserPreferences copyWith({
    String? userId,
    List<DietaryRestriction>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? dislikedIngredients,
    Map<MealType, bool>? mealTypePreferences,
    int? defaultServings,
    int? maxPrepTime,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      mealTypePreferences: mealTypePreferences ?? this.mealTypePreferences,
      defaultServings: defaultServings ?? this.defaultServings,
      maxPrepTime: maxPrepTime ?? this.maxPrepTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dietaryRestrictions': dietaryRestrictions.map((e) => e.name).toList(),
      'allergies': allergies,
      'dislikedIngredients': dislikedIngredients,
      'mealTypePreferences': mealTypePreferences.map((k, v) => MapEntry(k.name, v)),
      'defaultServings': defaultServings,
      'maxPrepTime': maxPrepTime,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] as String,
      dietaryRestrictions: (map['dietaryRestrictions'] as List?)
          ?.map((e) => DietaryRestriction.values.firstWhere(
                (d) => d.name == e,
                orElse: () => DietaryRestriction.vegetarian,
              ))
          .toList() ?? [],
      allergies: List<String>.from(map['allergies'] ?? []),
      dislikedIngredients: List<String>.from(map['dislikedIngredients'] ?? []),
      mealTypePreferences: Map<String, bool>.from(
        map['mealTypePreferences'] as Map? ?? {}
      ).map(
        (key, value) => MapEntry(
          MealType.values.firstWhere(
            (e) => e.name == key,
            orElse: () => MealType.dinner,
          ),
          value,
        ),
      ),
      defaultServings: map['defaultServings'] as int? ?? 2,
      maxPrepTime: map['maxPrepTime'] as int? ?? 60,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}