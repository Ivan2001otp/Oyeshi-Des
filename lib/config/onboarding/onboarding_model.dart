// onboarding_models.dart

class OnboardingRemoteConfig {
  final OnboardingPayloadConfig onboardingConfig;

  OnboardingRemoteConfig({
    required this.onboardingConfig,
  });

  factory OnboardingRemoteConfig.fromJson(Map<String, dynamic> json) {
    return OnboardingRemoteConfig(
      onboardingConfig: OnboardingPayloadConfig.fromJson(
          json['onboarding_config'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboarding_config': onboardingConfig.toJson(),
    };
  }
}

class OnboardingPayloadConfig {
  final String version;
  final bool active;
  final int total;
  final List<OnboardingQuestion> questions;

  OnboardingPayloadConfig({
    required this.version,
    required this.active,
    required this.total,
    required this.questions,
  });

  factory OnboardingPayloadConfig.fromJson(Map<String, dynamic> json) {
    return OnboardingPayloadConfig(
      version: json['version'] as String,
      active: json['active'] as bool,
      total: json['total'] as int,
      questions: (json['questions'] as List<dynamic>?)
              ?.map(
                  (q) => OnboardingQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'active': active,
      'total': total,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  OnboardingQuestion? getQuestionById(String id) {
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  OnboardingQuestion? getQuestionByIndex(int index) {
    if (index < 0 || index >= questions.length) return null;
    return questions[index];
  }
}

class OnboardingQuestion {
  final String id;
  final String type;
  final String text;
  final List<QuestionOption> options;
  final String nextStep;
  final String? buttonText; // Only for final_cta type

  const OnboardingQuestion({
    required this.id,
    required this.type,
    required this.text,
    required this.options,
    required this.nextStep,
    this.buttonText,
  });

  factory OnboardingQuestion.fromJson(Map<String, dynamic> json) {
    return OnboardingQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map(
                  (opt) => QuestionOption.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          const [],
      nextStep: json['next_step'] as String,
      buttonText: json['button_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'type': type,
      'text': text,
      'options': options.map((opt) => opt.toJson()).toList(),
      'next_step': nextStep,
      'button_text': buttonText,
    };

    if (buttonText != null) {
      json['button_text'] = buttonText;
    }

    return json;
  }

  bool get isFinalCTA => type == 'final_cta';
  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isEmpty => id.isEmpty;
}

class QuestionOption {
  final String id;
  final String text;

  const QuestionOption({
    required this.id,
    required this.text,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}
