import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_event.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_state.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/models/recipe.dart';
import 'package:oyeshi_des/services/ai_service.dart';
import 'package:oyeshi_des/repositories/ingredient_repository.dart';
import 'package:uuid/uuid.dart';

class IngredientInputBloc
    extends Bloc<IngredientInputEvent, IngredientInputState> {
  final IngredientRepository _ingredientRepository;
  final AIService _aiService;
  final String _userId;
  final List<Ingredient> _tempIngredients = [];

  IngredientInputBloc({
    required IngredientRepository ingredientRepository,
    required AIService aiService,
    required String userId,
  })  : _ingredientRepository = ingredientRepository,
        _aiService = aiService,
        _userId = userId,
        super(const IngredientInputInitial()) {
    on<IngredientTextChanged>(_onTextChanged);
    on<IngredientSubmitted>(_onIngredientSubmitted);
    // on<ParseIngredientsFromText>(_onParseIngredientsFromText);
    on<ClearIngredients>(_onClearIngredients);
    on<RemoveIngredient>(_onRemoveIngredient);
    // on<IngredientAdded>(_onIngredientAdded);
    on<GenerateMealPlanEvent>(_onGenerateMealPlan);
  }

  Future<void> _onTextChanged(
    IngredientTextChanged event,
    Emitter<IngredientInputState> emit,
  ) async {
    final currentState = state;
    if (currentState is IngredientInputLoaded) {
      emit(currentState.copyWith(inputText: event.text));
    } else {
      emit(IngredientInputLoaded(
        ingredients: _tempIngredients,
        inputText: event.text,
      ));
    }
  }

  Future<void> _onIngredientSubmitted(
    IngredientSubmitted event,
    Emitter<IngredientInputState> emit,
  ) async {
    // if (event.text.trim().isEmpty) return;
    if (event.texts.isEmpty) return;

    emit(const IngredientInputLoading());
    
    try {

      for (final text in event.texts) {

        if (text.trim().isEmpty) continue;
        
        final foodIngredient = Ingredient(
          id: const Uuid().v4(),
          name: text.trim(),
          category: _categorizeIngredient(text.trim()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _tempIngredients.add(foodIngredient);
      }
/*
      final ingredient = Ingredient(
        id: const Uuid().v4(),
        name: event.text.trim(),
        category: _categorizeIngredient(event.text.trim()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _tempIngredients.add(ingredient);
*/
      final currentState = state;
      if (currentState is IngredientInputLoaded) {
        emit(currentState.copyWith(
          ingredients: List.from(_tempIngredients),
          inputText: '',
        ));
      } else {
        emit(IngredientInputLoaded(
          ingredients: _tempIngredients,
          inputText: '',
        ));
      }

      await _ingredientRepository.addIngredients(_userId, _tempIngredients);
    } catch (e) {
      emit(IngredientInputError('Failed to add ingredient: $e'));
    }
  }
/*
  Future<void> _onParseIngredientsFromText(
    ParseIngredientsFromText event,
    Emitter<IngredientInputState> emit,
  ) async {
    if (event.text.trim().isEmpty) return;

    emit(const IngredientInputLoading());

    try {
      final parsedIngredients =
          await _aiService.parseIngredientsFromText(event.text);

      final ingredients = parsedIngredients
          .map((name) => Ingredient(
                id: const Uuid().v4(),
                name: name.trim(),
                category: _categorizeIngredient(name.trim()),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList();

      for (final ingredient in ingredients) {
        _tempIngredients.add(ingredient);
        await _ingredientRepository.addIngredient(_userId, ingredient);
      }

      final currentState = state;
      if (currentState is IngredientInputLoaded) {
        emit(currentState.copyWith(
          ingredients: List.from(_tempIngredients),
          parsedIngredients: parsedIngredients,
          inputText: '',
        ));
      } else {
        emit(IngredientInputLoaded(
          ingredients: _tempIngredients,
          parsedIngredients: parsedIngredients,
          inputText: '',
        ));
      }
    } catch (e) {
      emit(IngredientInputError('Failed to parse ingredients: $e'));
    }
  }
*/
  Future<void> _onClearIngredients(
    ClearIngredients event,
    Emitter<IngredientInputState> emit,
  ) async {
    _tempIngredients.clear();
    emit(const IngredientInputLoaded(ingredients: []));
  }

  Future<void> _onRemoveIngredient(
    RemoveIngredient event,
    Emitter<IngredientInputState> emit,
  ) async {
    try {
      _tempIngredients
          .removeWhere((ingredient) => ingredient.id == event.ingredientId);
      await _ingredientRepository.deleteIngredient(_userId, event.ingredientId);

      final currentState = state;
      if (currentState is IngredientInputLoaded) {
        emit(currentState.copyWith(
          ingredients: List.from(_tempIngredients),
        ));
      }
    } catch (e) {
      emit(IngredientInputError('Failed to remove ingredient: $e'));
    }
  }

  Future<void> _onGenerateMealPlan(
    GenerateMealPlanEvent event,
    Emitter<IngredientInputState> emit,
  ) async {
    if (_tempIngredients.isEmpty) {
      emit(
          const IngredientInputError('No ingredients available for meal plan'));
      return;
    }

    emit(const IngredientInputLoading());

    try {
      final recipes = await _aiService.generateMealPlan(
        _tempIngredients,
        event.dietaryRestrictions,
        event.allergies,
        event.dislikedIngredients,
        event.mealTypePreferences,
      );

      emit(MealPlanGenerated(recipes));
    } catch (e) {
      emit(IngredientInputError('Failed to generate meal plan: $e'));
    }
  }

  void generateMealPlan({
    required List<String> dietaryRestrictions,
    required List<String> allergies,
    required List<String> dislikedIngredients,
    required Map<String, bool> mealTypePreferences,
  }) {
    if (_tempIngredients.isEmpty) {
      return;
    }

    add(GenerateMealPlanEvent(
      dietaryRestrictions: dietaryRestrictions,
      allergies: allergies,
      dislikedIngredients: dislikedIngredients,
      mealTypePreferences: mealTypePreferences,
    ));
  }

  String _categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();

    if (name.contains('milk') ||
        name.contains('cheese') ||
        name.contains('yogurt')) {
      return 'Dairy';
    } else if (name.contains('chicken') ||
        name.contains('beef') ||
        name.contains('pork') ||
        name.contains('fish')) {
      return 'Protein';
    } else if (name.contains('tomato') ||
        name.contains('onion') ||
        name.contains('carrot') ||
        name.contains('lettuce')) {
      return 'Vegetables';
    } else if (name.contains('apple') ||
        name.contains('banana') ||
        name.contains('orange')) {
      return 'Fruits';
    } else if (name.contains('rice') ||
        name.contains('pasta') ||
        name.contains('bread')) {
      return 'Grains';
    } else if (name.contains('oil') ||
        name.contains('butter') ||
        name.contains('salt') ||
        name.contains('pepper')) {
      return 'Pantry';
    } else {
      return 'Other';
    }
  }
}
