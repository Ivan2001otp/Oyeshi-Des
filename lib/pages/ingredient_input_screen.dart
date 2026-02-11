import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_event.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_state.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/pages/meal_planning_screen.dart';

class IngredientInputScreen extends StatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  State<IngredientInputScreen> createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends State<IngredientInputScreen> {
  final List<TextEditingController> _ingredientControllers = [];

  @override
  void dispose() {
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          /*if (context.watch<IngredientInputBloc>().state
                  is IngredientInputLoaded &&
              (context.watch<IngredientInputBloc>().state
                      as IngredientInputLoaded)
                  .ingredients
                  .isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restaurant_menu, color: Colors.black,),
              onPressed: () => _showMealPlanDialog(context),
            ),*/
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
              // const SizedBox(height: 24),
              // _buildIngredientsList(context),
            ],
          ),
        ),
      ),
    );
  }

  void _addTextController(BuildContext context) {
    if (_ingredientControllers.length >= 20) {
      // Optional: Show a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Max 20 ingredients allowed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add an ingredient:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),

        // Scrollable list with max height constraint
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._ingredientControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.name,
                            minLines: 1,
                            controller: controller,
                            maxLength: 20,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Eggs',
                              hintStyle: TextStyle(color: Color.fromARGB(255, 193, 190, 190)),
                              icon: Icon(Icons.local_dining_outlined),
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              controller.dispose();
                              _ingredientControllers.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Show counter and limit message
        Text(
          '${_ingredientControllers.length}/20 ingredients',
          style: TextStyle(
            fontSize: 12,
            color:
                _ingredientControllers.length >= 20 ? Colors.red : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        ElevatedButton(
          onPressed: _ingredientControllers.length >= 20
              ? null // Disable when limit reached
              : () => _addTextController(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text(
            'Add Ingredient +',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: _ingredientControllers.isEmpty
              ? null // Disable if no ingredients
              : () async {
                  _submitIngredientList(context);
                },
          icon: const Icon(Icons.restaurant, color: Colors.white,),
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          label: const Text("Generate Meal Plans", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
        ),
      ],
    );
  }

/*
  void _addTextController(BuildContext ctx) {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }
*/
  void _submitIngredientList(BuildContext ctx) {
    List<String> ingredients = [];

    for (var controller in _ingredientControllers) {
      ingredients.add(controller.text.trim());
    }

    context.read<IngredientInputBloc>().add(IngredientSubmitted(ingredients));

    final parsedIngredients = ingredients
        .map(
          (name) => Ingredient(
              id: 'scan_${DateTime.now().millisecondsSinceEpoch}_${ingredients.indexOf(name)}',
              name: name,
              category: 'ManualText',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()),
        )
        .toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MealPlanningScreen(ingredients: parsedIngredients,)),
    );
    /*
      Navigator.of(dialogContext).pop();

              final parsedIngredients = ingredients
                  .map((name) => Ingredient(
                        id: 'scan_${DateTime.now().millisecondsSinceEpoch}_${ingredients.indexOf(name)}',
                        name: name,
                        category: 'Scanned',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ))
                  .toList();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      MealPlanningScreen(ingredients: parsedIngredients),
                ),
              );
     */
  }

  /*void _addSingleIngredient(BuildContext context, String text) {
    if (text.trim().isEmpty) return;

    context.read<IngredientInputBloc>().add(IngredientSubmitted(text.trim()));
    _textController.clear();
  }*/

  /*void _removeIngredient(BuildContext context, String ingredientId) {
    context.read<IngredientInputBloc>().add(RemoveIngredient(ingredientId));
  }*/

  void _clearAllIngredients(BuildContext context) {
    context.read<IngredientInputBloc>().add(ClearIngredients());
  }

  void _showMealPlanDialog(BuildContext context, List<String> foodIngredients) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Generate Meal Plan'),
          content: const Text(
              'Generate recipes based on your available ingredients?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _generateMealPlan(context, foodIngredients);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _generateMealPlan(BuildContext context, List<String> foodIngredients) {
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

  const MealPlanResultsScreen({Key? key, required this.recipes})
      : super(key: key);

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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.description),
                  const SizedBox(height: 8),
                  Text('Meal Type: ${recipe.mealType}'),
                  Text('Prep Time: ${recipe.prepTimeMinutes} min'),
                  Text('Cook Time: ${recipe.cookTimeMinutes} min'),
                  Text('Servings: ${recipe.servings}'),
                  const SizedBox(height: 8),
                  const Text('Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...recipe.ingredients
                      .map((ingredient) => Text('• $ingredient')),
                  const SizedBox(height: 8),
                  const Text('Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...recipe.instructions
                      .asMap()
                      .entries
                      .map((entry) => Text('${entry.key + 1}. ${entry.value}')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
