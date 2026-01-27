import 'package:equatable/equatable.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/models/recipe.dart';

abstract class IngredientInputState extends Equatable {
  const IngredientInputState();

  @override
  List<Object> get props => [];
}

class IngredientInputInitial extends IngredientInputState {
  const IngredientInputInitial();
}

class IngredientInputLoading extends IngredientInputState {
  const IngredientInputLoading();
}

class IngredientInputLoaded extends IngredientInputState {
  final List<Ingredient> ingredients;
  final String inputText;
  final List<String> parsedIngredients;

  const IngredientInputLoaded({
    required this.ingredients,
    this.inputText = '',
    this.parsedIngredients = const [],
  });

  IngredientInputLoaded copyWith({
    List<Ingredient>? ingredients,
    String? inputText,
    List<String>? parsedIngredients,
  }) {
    return IngredientInputLoaded(
      ingredients: ingredients ?? this.ingredients,
      inputText: inputText ?? this.inputText,
      parsedIngredients: parsedIngredients ?? this.parsedIngredients,
    );
  }

  @override
  List<Object> get props => [ingredients, inputText, parsedIngredients];
}

class IngredientInputError extends IngredientInputState {
  final String message;

  const IngredientInputError(this.message);

  @override
  List<Object> get props => [message];
}

class IngredientsParsed extends IngredientInputState {
  final List<String> ingredients;

  const IngredientsParsed(this.ingredients);

  @override
  List<Object> get props => [ingredients];
}

class MealPlanGenerated extends IngredientInputState {
  final List<Recipe> recipes;

  const MealPlanGenerated(this.recipes);

  @override
  List<Object> get props => [recipes];
}