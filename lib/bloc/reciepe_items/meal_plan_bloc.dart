import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/services/ai_service.dart';

import 'meal_plan_event.dart';
import 'meal_plan_state.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final AIService _aiService;

  MealPlanBloc({required AIService aiService})
      : _aiService = aiService,
        super(MealPlanInitial()) {
    on<GenerateMealPlan>(_onGenerateMealPlan);
    on<ResetMealPlan>(_onResetMealPlan);
  }

  void _onResetMealPlan(
    ResetMealPlan event,
    Emitter<MealPlanState> emit,
  ) {
    emit(MealPlanInitial());
  }

  Future<void> _onGenerateMealPlan(
      GenerateMealPlan event, Emitter<MealPlanState> emit) async {
    emit(MealPlanLoading(message: "Generating delicious meal plan..."));

    try {
      final recipes = await _aiService.generateMealPlan(
          event.ingredients,
          event.dietaryRestrictions,
          event.allergies,
          event.dislikedIngredients,
          event.mealTypePreferences);

      if (recipes.isEmpty) {
        emit(MealPlanError(
          errorMessage:
              'No recipes found for these ingredients. Try adding more ingredients.',
        ));
        return;
      }

      emit(MealPlanGenerated(recipes: recipes));
    } catch (error) {
      emit(MealPlanError(errorMessage: 'Failed to generate meal plan: $error'));
    }
  }
}
