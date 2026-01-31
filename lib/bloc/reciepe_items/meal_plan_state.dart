import '../../models/recipe.dart';

abstract class MealPlanState {}

class MealPlanInitial extends MealPlanState {}

class MealPlanLoading extends MealPlanState {
  final String message;
  MealPlanLoading({required this.message});
}


class MealPlanGenerated extends MealPlanState {
  final List<Recipe> recipes;
  MealPlanGenerated({required this.recipes});
}

class MealPlanError extends MealPlanState {
  final String errorMessage;
  MealPlanError({required this.errorMessage});
}