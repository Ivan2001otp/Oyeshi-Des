import '../../models/ingredient.dart';

abstract class MealPlanEvent {}


class ResetMealPlan extends MealPlanEvent {}

class GenerateMealPlan extends MealPlanEvent {
   final List<Ingredient> ingredients;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final Map<String, bool> mealTypePreferences;

  GenerateMealPlan({
    required this.ingredients,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.dislikedIngredients = const [],
    this.mealTypePreferences = const {
      'breakfast': true,
      'lunch': true,
      'dinner': true,
      'snack': true,
    },
  });
}