import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class GoogleAnalyticsService {
  // Singleton instance
  static final GoogleAnalyticsService _instance =
      GoogleAnalyticsService._internal();

  // Private constructor
  GoogleAnalyticsService._internal();

  // Factory constructor
  factory GoogleAnalyticsService() => _instance;

  // Firebase Analytics instance
  late final FirebaseAnalytics _analytics;

  // Observer for navigation tracking
  late final FirebaseAnalyticsObserver _observer;

  // Initialize method - call once in main.dart
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;

    // Set default parameters
    await _analytics.setDefaultEventParameters({
      'app_name': 'FoodSaver',
      'app_version': '1.0.0',
      'platform': 'flutter',
    });

    // Create observer for screen tracking
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Getter for analytics instance
  FirebaseAnalytics get analytics => _analytics;

  // Getter for observer (for MaterialApp navigatorObservers)
  FirebaseAnalyticsObserver get observer => _observer;

  // ---------- User Properties ----------

  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ---------- Screen Tracking ----------

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ---------- Onboarding Events ----------

  Future<void> logOnboardingStarted({required String variant}) async {
    await _analytics.logEvent(
      name: 'onboarding_started',
      parameters: {
        'onboarding_variant': variant,
      },
    );
  }

  Future<void> logOnboardingQuestionAnswered({
    required String questionId,
    required String questionKey,
    required String answerId,
    required String answerValue,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_question_answered',
      parameters: {
        'question_id': questionId,
        'question_key': questionKey,
        'answer_id': answerId,
        'answer_value': answerValue,
      },
    );
  }

  Future<void> logOnboardingCompleted({
    required String variant,
    required int totalQuestions,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_completed',
      parameters: {
        'onboarding_variant': variant,
        'total_questions': totalQuestions,
      },
    );
  }

  // ---------- Paywall Events ----------

  Future<void> logPaywallViewed({required String source}) async {
    await _analytics.logEvent(
      name: 'paywall_viewed',
      parameters: {
        'source': source,
      },
    );
  }

  Future<void> logPaywallPlanSelected({
    required String planId,
    required String planName,
    required String price,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_plan_selected',
      parameters: {
        'plan_id': planId,
        'plan_name': planName,
        'price': price,
      },
    );
  }

  Future<void> logSubscriptionStarted({
    required String productId,
    required String planType,
    required double price,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {
        'product_id': productId,
        'plan_type': planType,
        'price': price,
        'currency': currency,
      },
    );
  }

  Future<void> logSubscriptionCompleted({
    required String productId,
    required String planType,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_completed',
      parameters: {
        'product_id': productId,
        'plan_type': planType,
      },
    );
  }

  // ---------- Food Waste Events ----------

  Future<void> logIngredientsScanned({required int count}) async {
    await _analytics.logEvent(
      name: 'ingredients_scanned',
      parameters: {
        'ingredient_count': count,
      },
    );
  }

  Future<void> logVoiceInputUsed() async {
    await _analytics.logEvent(name: 'voice_input_used');
  }

  Future<void> logMealPlanGenerated({required int recipeCount}) async {
    await _analytics.logEvent(
      name: 'meal_plan_generated',
      parameters: {
        'recipe_count': recipeCount,
      },
    );
  }

  Future<void> logFoodWasteSaved({required double estimatedSavings}) async {
    await _analytics.logEvent(
      name: 'food_waste_saved',
      parameters: {
        'estimated_savings_usd': estimatedSavings,
      },
    );
  }

  // ---------- General Events ----------

  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters ,
    );
  }

  // ---------- Debug & Testing ----------
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }

  // ---------- E-commerce/Purchase Events ----------

  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logEvent(
      name: 'purchase',
      parameters: {
        'transaction_id': transactionId,
        'value': value,
        'currency': currency,
        'items': items,
        'tax': 0.0,
        'shipping': 0.0,
      },
    );
  }
}

// Global accessor for easy use throughout the app
GoogleAnalyticsService get analyticsService => GoogleAnalyticsService();
