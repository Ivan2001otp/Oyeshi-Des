import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:oyeshi_des/config/dependency_injection.dart';
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
  Future<bool> saveRecipe(Recipe recipe) async {
    debugPrint('Saving recipe: ${recipe.name}');

    final firestoreInstance = getIt<FirebaseFirestore>();

    try {
      final batch = firestoreInstance.batch();
      final ingredientsRef = firestoreInstance
          .collection("users")
          .doc("demo_user")
          .collection("bookmarked");

      final docRef = ingredientsRef.doc(recipe.id);
      batch.set(docRef, recipe.toMap());
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Failed to save recipe: $e');
      return false;
    }
  }

  @override
  Future<void> rateRecipe(String recipeId, double rating) async {
    throw UnimplementedError('Rating implementation needed');
  }
}
