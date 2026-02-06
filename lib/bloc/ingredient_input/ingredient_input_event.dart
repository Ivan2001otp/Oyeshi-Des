import 'package:equatable/equatable.dart';
import 'package:oyeshi_des/models/ingredient.dart';

abstract class IngredientInputEvent extends Equatable {
  const IngredientInputEvent();

  @override
  List<Object> get props => [];
}

class IngredientTextChanged extends IngredientInputEvent {
  final String text;

  const IngredientTextChanged(this.text);

  @override
  List<Object> get props => [text];
}

class IngredientSubmitted extends IngredientInputEvent {
  final List<String> texts;

  const IngredientSubmitted(this.texts);

  @override
  List<Object> get props => [texts];
}

class IngredientAdded extends IngredientInputEvent {
  final Ingredient ingredient;

  const IngredientAdded(this.ingredient);

  @override
  List<Object> get props => [ingredient];
}

class ParseIngredientsFromText extends IngredientInputEvent {
  final String text;

  const ParseIngredientsFromText(this.text);

  @override
  List<Object> get props => [text];
}

class ClearIngredients extends IngredientInputEvent {
  @override
  List<Object> get props => [];
}

class RemoveIngredient extends IngredientInputEvent {
  final String ingredientId;

  const RemoveIngredient(this.ingredientId);

  @override
  List<Object> get props => [ingredientId];
}

class GenerateMealPlanEvent extends IngredientInputEvent {
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> dislikedIngredients;
  final Map<String, bool> mealTypePreferences;

  const GenerateMealPlanEvent({
    required this.dietaryRestrictions,
    required this.allergies,
    required this.dislikedIngredients,
    required this.mealTypePreferences,
  });

  @override
  List<Object> get props => [
    dietaryRestrictions,
    allergies,
    dislikedIngredients,
    mealTypePreferences,
  ];
}