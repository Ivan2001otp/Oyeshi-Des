import 'package:oyeshi_des/models/recipe.dart';
import 'package:oyeshi_des/models/ingredient.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients);
  Future<List<Recipe>> getRecipesByMealType(MealType mealType);
  Future<Recipe?> getRecipe(String recipeId);
  Future<List<Recipe>> searchRecipes(String query);
  Future<void> saveRecipe(Recipe recipe);
  Future<void> rateRecipe(String recipeId, double rating);
}

class RecipeRepositoryImpl implements RecipeRepository {
  @override
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients) async {
    throw UnimplementedError('AI integration needed for recipe generation');
  }

  @override
  Future<List<Recipe>> getRecipesByMealType(MealType mealType) async {
    throw UnimplementedError('Firestore implementation needed');
  }

  @override
  Future<Recipe?> getRecipe(String recipeId) async {
    throw UnimplementedError('Firestore implementation needed');
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    throw UnimplementedError('Search implementation needed');
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    throw UnimplementedError('Firestore implementation needed');
  }

  @override
  Future<void> rateRecipe(String recipeId, double rating) async {
    throw UnimplementedError('Rating implementation needed');
  }
}