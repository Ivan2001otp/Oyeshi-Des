import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/models/recipe.dart';
import 'package:oyeshi_des/services/ai_service.dart';
import 'package:oyeshi_des/config/dependency_injection.dart';

import '../bloc/reciepe_items/meal_plan_bloc.dart';
import '../bloc/reciepe_items/meal_plan_event.dart';
import '../bloc/reciepe_items/meal_plan_state.dart';
import '../repositories/recipe_repository.dart';

class MealPlanningScreen extends StatelessWidget {
  final List<Ingredient> ingredients;

  const MealPlanningScreen({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MealPlanBloc(
        aiService: getIt<AIService>(),
      )..add(GenerateMealPlan(
          ingredients: ingredients,
          // You can add user preferences here later
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Meal Planning',
            style: TextStyle(fontSize: 14),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<MealPlanBloc, MealPlanState>(
          builder: (context, state) {
            if (state is MealPlanInitial) {
              return _buildInitialState();
            } else if (state is MealPlanLoading) {
              return _buildLoadingState(state.message);
            } else if (state is MealPlanGenerated) {
              return _buildRecipesList(context, state.recipes);
            } else if (state is MealPlanError) {
              return _buildErrorState(context, state.errorMessage);
            }
            return _buildLoadingState('Loading...');
          },
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text('Preparing to generate meal plan...'),
          const SizedBox(height: 10),
          Text(
            'Ingredients: ${ingredients.map((i) => i.name).join(', ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(message),
          const SizedBox(height: 10),
          const Text(
            'Analyzing ingredients and creating delicious recipes...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(BuildContext context, List<Recipe> recipes) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.green),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${recipes.length} Delicious Recipes Found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<MealPlanBloc>().add(
                        GenerateMealPlan(ingredients: ingredients),
                      );
                },
                tooltip: 'Generate new recipes',
              ),
            ],
          ),
        ),

        // Recipes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _buildRecipeCard(context, recipe);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getMealTypeColor(recipe.mealType),
                  child: Text(
                    recipe.mealType.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${recipe.mealType.name.toUpperCase()} • ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min • ${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              recipe.description,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Dietary tags
            if (recipe.dietaryTags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: recipe.dietaryTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(fontSize: 11),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Ingredients preview
            Text(
              'Ingredients: ${recipe.ingredients.take(3).join(', ')}${recipe.ingredients.length > 3 ? '...' : ''}',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // View recipe button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showRecipeDetails(context, recipe);
                    },
                    child: const Text('View Recipe'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () async {
                    final repository = getIt<RecipeRepositoryImpl>();
                    bool result = await repository.saveRecipe(recipe);
                    if (context.mounted) {
                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Recipe saved to bookmarks!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.amber,
                            content: Text(
                              'Failed to save recipe. Please try again.',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.read<MealPlanBloc>().add(
                      GenerateMealPlan(ingredients: ingredients),
                    );
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return Colors.blue;
    }
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.schedule, 'Total Time',
                    '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} minutes'),
                _buildDetailRow(Icons.people, 'Servings', '${recipe.servings}'),
                _buildDetailRow(Icons.restaurant, 'Meal Type',
                    recipe.mealType.name.toUpperCase()),
                const SizedBox(height: 20),
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...recipe.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...recipe.instructions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Start cooking mode
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Start Cooking'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
