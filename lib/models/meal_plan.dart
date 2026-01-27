class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final Map<MealType, String> recipes; // mealType -> recipeId
  final List<String> usedIngredients;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.recipes,
    required this.usedIngredients,
    required this.createdAt,
  });

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Map<MealType, String>? recipes,
    List<String>? usedIngredients,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      recipes: recipes ?? this.recipes,
      usedIngredients: usedIngredients ?? this.usedIngredients,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'recipes': recipes.map((k, v) => MapEntry(k.name, v)),
      'usedIngredients': usedIngredients,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      recipes: Map<String, String>.from(map['recipes'] as Map).map(
        (key, value) => MapEntry(
          MealType.values.firstWhere(
            (e) => e.name == key,
            orElse: () => MealType.dinner,
          ),
          value,
        ),
      ),
      usedIngredients: List<String>.from(map['usedIngredients'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

enum MealType { breakfast, lunch, dinner, snack }