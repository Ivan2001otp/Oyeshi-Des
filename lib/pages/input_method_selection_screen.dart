import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_event.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_bloc.dart';
import 'package:oyeshi_des/pages/ingredient_input_screen.dart';
import 'package:oyeshi_des/pages/audio_input_screen.dart';
import 'package:oyeshi_des/config/dependency_injection.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/services/ai_service.dart';

import '../bloc/text_scan/text_scan_bloc.dart';
import 'ingredient_text_scan_screen.dart';

class InputMethodSelectionScreen extends StatelessWidget {
  const InputMethodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Oyeshi Des',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildInputMethods(context),
              const SizedBox(height: 32),
              /*_buildCurrentIngredients(context),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        const Text(
          'Choose Input Method',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you want to add your ingredients',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputMethods(BuildContext context) {
    return Column(
      children: [
        _buildInputMethodCard(
          context,
          icon: Icons.keyboard,
          title: 'Text Input',
          description: 'Type ingredients manually or paste a list',
          onTap: () => _navigateToTextInput(context),
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildInputMethodCard(
          context,
          icon: Icons.mic,
          title: 'Voice Input',
          description: 'Speak your ingredients aloud',
          onTap: () => _navigateToVoiceInput(context),
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildInputMethodCard(
          context,
          icon: Icons.camera_alt,
          title: 'Camera Scan',
          description: 'Take a photo of ingredients',
          onTap: () => _navigateToAIreaderInputFromNotesTypeInput(context),
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildInputMethodCard(
          context,
          icon: Icons.photo_library,
          title: 'Image Upload',
          description: 'Upload an image of ingredients',
          onTap: () => _showComingSoon(context, 'Image Upload'),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildInputMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

/*
  Widget _buildCurrentIngredients(BuildContext context) {
    return BlocBuilder<IngredientInputBloc, IngredientInputState>(
      builder: (context, state) {
        if (state is IngredientInputLoaded && state.ingredients.isNotEmpty) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Ingredients (${state.ingredients.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _viewAllIngredients(context),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.ingredients.take(10).length,
                      itemBuilder: (context, index) {
                        final ingredient = state.ingredients[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      ingredient.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ingredient.name,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.ingredients.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '...and ${state.ingredients.length - 10} more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
*/

  void _navigateToAIreaderInputFromNotesTypeInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => TextScanBloc(
            aiService: context.read<AIService>(),
          ),
          child: const IngredientTextScanScreen(),
        ),
      ),
    );
  }

  void _navigateToTextInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<IngredientInputBloc>(),
            ),
          ],
          child: const IngredientInputScreen(),
        ),
      ),
    );
  }

  void _navigateToVoiceInput(BuildContext context) async {
    final ingredientBloc = context.read<IngredientInputBloc>();

    final ingredients = await Navigator.push<List<Ingredient>>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AudioInputBloc(
            audioService: getIt(),
            aiService: getIt(),
            userId: 'demo_user',
          ),
          child: const AudioInputScreen(),
        ),
      ),
    );

    if (ingredients != null && ingredients.isNotEmpty) {
      // Add ingredients to the main ingredient input bloc
      for (final ingredient in ingredients) {
        ingredientBloc.add(IngredientAdded(ingredient));
      }
    }
  }

  void _viewAllIngredients(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<IngredientInputBloc>(),
            ),
          ],
          child: const IngredientInputScreen(),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is coming soon!'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
