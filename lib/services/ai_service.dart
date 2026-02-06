import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:oyeshi_des/models/recipe.dart';
import 'package:oyeshi_des/models/ingredient.dart';

abstract class AIService {
  Future<List<Recipe>> generateMealPlan(
    List<Ingredient> ingredients,
    List<String> dietaryRestrictions,
    List<String> allergies,
    List<String> dislikedIngredients,
    Map<String, bool> mealTypePreferences,
  );

  Future<List<String>> parseIngredientsFromText(String text);
  Future<List<Recipe>> searchRecipesByIngredients(List<Ingredient> ingredients);
}

class GeminiAIService implements AIService {
  final GenerativeModel _model;
  
  GeminiAIService(String apiKey) : _model = GenerativeModel(
    model: 'gemini-3-flash-preview',
    apiKey: apiKey,
  );

  @override
  Future<List<Recipe>> generateMealPlan(
    List<Ingredient> ingredients,
    List<String> dietaryRestrictions,
    List<String> allergies,
    List<String> dislikedIngredients,
    Map<String, bool> mealTypePreferences,
  ) async {
    try {
      final ingredientNames = ingredients.map((i) => i.name).join(', ');
      final dietaryInfo = dietaryRestrictions.isNotEmpty 
          ? 'Dietary restrictions: ${dietaryRestrictions.join(', ')}'
          : '';
      final allergyInfo = allergies.isNotEmpty 
          ? 'Allergies to avoid: ${allergies.join(', ')}'
          : '';
      final dislikedInfo = dislikedIngredients.isNotEmpty 
          ? 'Disliked ingredients: ${dislikedIngredients.join(', ')}'
          : '';
      
      final mealTypes = mealTypePreferences.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');

      final prompt = '''
      Create a detailed meal plan using these available ingredients: $ingredientNames
      
      Requirements:
      - $dietaryInfo
      - $allergyInfo
      - $dislikedInfo
      - Meal types to include: $mealTypes
      
      For each recipe, provide:
      - Name (clear and descriptive)
      - Short description
      - Meal type (breakfast, lunch, dinner, snack)
      - Prep time in minutes
      - Cook time in minutes  
      - Number of servings
      - List of ingredients with quantities
      - Step-by-step instructions
      - Dietary tags (vegetarian, vegan, gluten-free, etc.)

      Format your response as a JSON array with the following structure:
      {
        "recipes": [
          {
            "name": "Recipe Name",
            "description": "Brief description",
            "mealType": "breakfast|lunch|dinner|snack",
            "prepTimeMinutes": 15,
            "cookTimeMinutes": 30,
            "servings": 2,
            "ingredients": ["ingredient1", "ingredient2"],
            "instructions": ["step1", "step2"],
            "dietaryTags": ["vegetarian", "gluten-free"]
          }
        ]
      }
      
      Ensure all recipes are practical, delicious, and properly formatted as valid JSON.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      return _parseRecipesFromResponse(responseText);
    } catch (e) {
      throw Exception('Failed to generate meal plan: $e');
    }
  }

  @override
  Future<List<String>> parseIngredientsFromText(String text) async {
    try {
      final prompt = '''
      Extract food ingredients from this text: "$text"
      
      Return only the ingredient names, one per line, without quantities or measurements.
      Focus on actual food items, ignore non-food items.
      
      Example format:
      tomatoes
      onions
      chicken breast
      rice
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      return responseText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && _isIngredient(line))
          .toList();
    } catch (e) {
      throw Exception('Failed to parse ingredients: $e');
    }
  }

  @override
  Future<List<Recipe>> searchRecipesByIngredients(List<Ingredient> ingredients) async {
    try {
      final ingredientNames = ingredients.map((i) => i.name).join(', ');
      
      final prompt = '''
      Create 3-5 recipes using these ingredients: $ingredientNames
      
      For each recipe, provide:
      - Name
      - Description
      - Meal type
      - Prep time (minutes)
      - Cook time (minutes)
      - Servings
      - Required ingredients with quantities
      - Step-by-step instructions
      - Dietary tags

      Format as JSON:
      {
        "recipes": [
          {
            "name": "Recipe Name",
            "description": "Brief description", 
            "mealType": "breakfast|lunch|dinner|snack",
            "prepTimeMinutes": 15,
            "cookTimeMinutes": 30,
            "servings": 2,
            "ingredients": ["ingredient1", "ingredient2"],
            "instructions": ["step1", "step2"],
            "dietaryTags": ["tag1", "tag2"]
          }
        ]
      }
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      return _parseRecipesFromResponse(responseText);
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  List<Recipe> _parseRecipesFromResponse(String responseText) {
    try {
      // Extract JSON from response (in case there's extra text)
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');
      
      if (jsonStart == -1 || jsonEnd == -1) {
        return [];
      }

      final jsonString = responseText.substring(jsonStart, jsonEnd + 1);
      final Map<String, dynamic> json = _parseJsonSafely(jsonString);
      
      if (json.containsKey('recipes')) {
        final recipesJson = json['recipes'] as List;
        return recipesJson.map((recipeJson) => _recipeFromJson(recipeJson)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error parsing recipes: $e');
      return [];
    }
  }

  Recipe _recipeFromJson(Map<String, dynamic> json) {
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Unknown Recipe',
      description: json['description'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      mealType: _parseMealType(json['mealType'] as String?),
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 15,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 30,
      servings: json['servings'] as int? ?? 2,
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      imageUrl: '',
      rating: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  MealType _parseMealType(String? mealTypeStr) {
    switch (mealTypeStr?.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.dinner;
    }
  }

  Map<String, dynamic> _parseJsonSafely(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON parsing error: $e');
      return {};
    }
  }

  bool _isIngredient(String word) {
    // Basic ingredient validation - expand this list as needed
    final commonIngredients = {
      'tomato', 'onion', 'garlic', 'potato', 'carrot', 'chicken', 'beef',
      'pork', 'rice', 'pasta', 'bread', 'milk', 'cheese', 'egg', 'butter',
      'oil', 'salt', 'pepper', 'flour', 'sugar', 'lettuce', 'cucumber',
      'onions', 'tomatoes', 'potatoes', 'carrots',
    };
    
    return commonIngredients.contains(word.toLowerCase()) || 
           word.length > 3; // Basic heuristic
  }
}