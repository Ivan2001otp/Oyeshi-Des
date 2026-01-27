import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_event.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_state.dart';
import 'package:oyeshi_des/models/ingredient.dart';

class IngredientInputScreen extends StatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  State<IngredientInputScreen> createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends State<IngredientInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _bulkTextController = TextEditingController();
  bool _isBulkMode = false;

  @override
  void dispose() {
    _textController.dispose();
    _bulkTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredients'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isBulkMode ? Icons.check_box : Icons.list_alt),
            onPressed: () {
              setState(() {
                _isBulkMode = !_isBulkMode;
              });
            },
          ),
          if (context.watch<IngredientInputBloc>().state is IngredientInputLoaded &&
              (context.watch<IngredientInputBloc>().state as IngredientInputLoaded).ingredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              onPressed: () => _showMealPlanDialog(context),
            ),
        ],
      ),
      body: BlocListener<IngredientInputBloc, IngredientInputState>(
        listener: (context, state) {
          if (state is IngredientInputError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MealPlanGenerated) {
            _showMealPlanResults(context, state.recipes);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputSection(context),
              const SizedBox(height: 24),
              _buildIngredientsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    if (_isBulkMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter multiple ingredients (one per line):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bulkTextController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tomatoes\nOnions\nChicken breast\nRice\nGarlic',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _parseBulkIngredients(context),
            child: const Text('Parse Ingredients'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add an ingredient:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'e.g., tomatoes, chicken breast, rice',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.add),
          ),
          onSubmitted: (value) => _addSingleIngredient(context, value),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _addSingleIngredient(context, _textController.text),
          child: const Text('Add Ingredient'),
        ),
      ],
    );
  }

  Widget _buildIngredientsList(BuildContext context) {
    return BlocBuilder<IngredientInputBloc, IngredientInputState>(
      builder: (context, state) {
        if (state is IngredientInputLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! IngredientInputLoaded) {
          return const Center(child: Text('Start adding ingredients!'));
        }

        if (state.ingredients.isEmpty) {
          return const Center(
            child: Text(
              'No ingredients added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added Ingredients (${state.ingredients.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => _clearAllIngredients(context),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = state.ingredients[index];
                  return _IngredientTile(
                    ingredient: ingredient,
                    onRemove: () => _removeIngredient(context, ingredient.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _addSingleIngredient(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    
    context.read<IngredientInputBloc>().add(IngredientSubmitted(text.trim()));
    _textController.clear();
  }

  void _parseBulkIngredients(BuildContext context) {
    final text = _bulkTextController.text.trim();
    if (text.isEmpty) return;
    
    context.read<IngredientInputBloc>().add(ParseIngredientsFromText(text));
    _bulkTextController.clear();
  }

  void _removeIngredient(BuildContext context, String ingredientId) {
    context.read<IngredientInputBloc>().add(RemoveIngredient(ingredientId));
  }

  void _clearAllIngredients(BuildContext context) {
    context.read<IngredientInputBloc>().add(ClearIngredients());
  }

  void _showMealPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Generate Meal Plan'),
          content: const Text('Generate recipes based on your available ingredients?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _generateMealPlan(context);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _generateMealPlan(BuildContext context) {
    final bloc = context.read<IngredientInputBloc>();
    bloc.generateMealPlan(
      dietaryRestrictions: [],
      allergies: [],
      dislikedIngredients: [],
      mealTypePreferences: {
        'breakfast': true,
        'lunch': true,
        'dinner': true,
        'snack': false,
      },
    );
  }

  void _showMealPlanResults(BuildContext context, List recipes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanResultsScreen(recipes: recipes),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onRemove;

  const _IngredientTile({
    required this.ingredient,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(ingredient.name[0].toUpperCase()),
        ),
        title: Text(ingredient.name),
        subtitle: Text(ingredient.category),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class MealPlanResultsScreen extends StatelessWidget {
  final List recipes;

  const MealPlanResultsScreen({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Meal Plan'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.description),
                  const SizedBox(height: 8),
                  Text('Meal Type: ${recipe.mealType}'),
                  Text('Prep Time: ${recipe.prepTimeMinutes} min'),
                  Text('Cook Time: ${recipe.cookTimeMinutes} min'),
                  Text('Servings: ${recipe.servings}'),
                  const SizedBox(height: 8),
                  const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...recipe.ingredients.map((ingredient) => Text('• $ingredient')),
                  const SizedBox(height: 8),
                  const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...recipe.instructions.asMap().entries.map((entry) => 
                    Text('${entry.key + 1}. ${entry.value}')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}