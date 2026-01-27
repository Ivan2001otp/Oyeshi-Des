import 'package:equatable/equatable.dart';
import 'package:oyeshi_des/models/ingredient.dart';

abstract class AudioInputState extends Equatable {
  const AudioInputState();

  @override
  List<Object> get props => [];
}

class AudioInputInitial extends AudioInputState {
  const AudioInputInitial();
}

class AudioInputLoading extends AudioInputState {
  const AudioInputLoading();
}

class AudioInputReady extends AudioInputState {
  final bool isListening;
  final String recognizedText;
  final List<String> partialResults;

  const AudioInputReady({
    this.isListening = false,
    this.recognizedText = '',
    this.partialResults = const [],
  });

  AudioInputReady copyWith({
    bool? isListening,
    String? recognizedText,
    List<String>? partialResults,
  }) {
    return AudioInputReady(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      partialResults: partialResults ?? this.partialResults,
    );
  }

  @override
  List<Object> get props => [isListening, recognizedText, partialResults];
}

class AudioInputListening extends AudioInputState {
  final String recognizedText;
  final List<String> partialResults;

  const AudioInputListening({
    this.recognizedText = '',
    this.partialResults = const [],
  });

  @override
  List<Object> get props => [recognizedText, partialResults];
}

class AudioInputCompleted extends AudioInputState {
  final String finalText;
  final List<Ingredient> parsedIngredients;

  const AudioInputCompleted({
    required this.finalText,
    required this.parsedIngredients,
  });

  @override
  List<Object> get props => [finalText, parsedIngredients];
}

class AudioInputError extends AudioInputState {
  final String message;

  const AudioInputError(this.message);

  @override
  List<Object> get props => [message];
}

class AudioInputPermissionDenied extends AudioInputState {
  const AudioInputPermissionDenied();
}