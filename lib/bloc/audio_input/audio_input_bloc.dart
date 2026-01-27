import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_event.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_state.dart';
import 'package:oyeshi_des/services/audio_input_service.dart';
import 'package:oyeshi_des/services/ai_service.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:uuid/uuid.dart';

class AudioInputBloc extends Bloc<AudioInputEvent, AudioInputState> {
  final AudioInputService _audioService;
  final AIService _aiService;
  final String _userId;
  String _currentRecognizedText = '';
  final List<String> _partialResults = [];

  AudioInputBloc({
    required AudioInputService audioService,
    required AIService aiService,
    required String userId,
  }) : _audioService = audioService,
       _aiService = aiService,
       _userId = userId,
       super(const AudioInputInitial()) {
    on<InitializeAudioInput>(_onInitialize);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<AudioRecognized>(_onAudioRecognized);
    on<ProcessAudioText>(_onProcessAudioText);
    on<ClearAudioInput>(_onClearAudioInput);
  }

  Future<void> _onInitialize(
    InitializeAudioInput event,
    Emitter<AudioInputState> emit,
  ) async {
    emit(const AudioInputLoading());
    
    try {
      final permissionsGranted = await _audioService.requestPermissions();
      if (!permissionsGranted) {
        emit(const AudioInputPermissionDenied());
        return;
      }

      final initialized = await _audioService.initialize();
      if (!initialized) {
        emit(const AudioInputError('Failed to initialize audio recognition'));
        return;
      }

      emit(const AudioInputReady());
    } catch (e) {
      emit(AudioInputError('Initialization failed: $e'));
    }
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<AudioInputState> emit,
  ) async {
    try {
      final isAvailable = await _audioService.isAvailable;
      if (!isAvailable) {
        emit(const AudioInputError('Audio recognition is not available'));
        return;
      }

      _currentRecognizedText = '';
      _partialResults.clear();

      emit(AudioInputListening(
        recognizedText: _currentRecognizedText,
        partialResults: _partialResults,
      ));

      await _audioService.startListening((recognizedWords) {
        add(AudioRecognized(recognizedWords));
      });
    } catch (e) {
      emit(AudioInputError('Failed to start listening: $e'));
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<AudioInputState> emit,
  ) async {
    try {
      await _audioService.stopListening();
      
      if (_currentRecognizedText.isNotEmpty) {
        add(ProcessAudioText(_currentRecognizedText));
      } else {
        emit(AudioInputReady(
          isListening: false,
          recognizedText: _currentRecognizedText,
          partialResults: _partialResults,
        ));
      }
    } catch (e) {
      emit(AudioInputError('Failed to stop listening: $e'));
    }
  }

  void _onAudioRecognized(
    AudioRecognized event,
    Emitter<AudioInputState> emit,
  ) {
    _currentRecognizedText = event.recognizedText;
    
    if (!_partialResults.contains(event.recognizedText)) {
      _partialResults.add(event.recognizedText);
    }

    if (state is AudioInputListening) {
      emit(AudioInputListening(
        recognizedText: _currentRecognizedText,
        partialResults: _partialResults,
      ));
    }
  }

  Future<void> _onProcessAudioText(
    ProcessAudioText event,
    Emitter<AudioInputState> emit,
  ) async {
    emit(const AudioInputLoading());

    try {
      final parsedIngredients = await _aiService.parseIngredientsFromText(event.audioText);
      
      final ingredients = parsedIngredients.map((name) => Ingredient(
        id: const Uuid().v4(),
        name: name.trim(),
        category: _categorizeIngredient(name.trim()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();

      emit(AudioInputCompleted(
        finalText: event.audioText,
        parsedIngredients: ingredients,
      ));
    } catch (e) {
      emit(AudioInputError('Failed to process audio: $e'));
    }
  }

  void _onClearAudioInput(
    ClearAudioInput event,
    Emitter<AudioInputState> emit,
  ) {
    _currentRecognizedText = '';
    _partialResults.clear();
    emit(const AudioInputReady());
  }

  String _categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();
    
    if (name.contains('milk') || name.contains('cheese') || name.contains('yogurt')) {
      return 'Dairy';
    } else if (name.contains('chicken') || name.contains('beef') || name.contains('pork') || name.contains('fish')) {
      return 'Protein';
    } else if (name.contains('tomato') || name.contains('onion') || name.contains('carrot') || name.contains('lettuce')) {
      return 'Vegetables';
    } else if (name.contains('apple') || name.contains('banana') || name.contains('orange')) {
      return 'Fruits';
    } else if (name.contains('rice') || name.contains('pasta') || name.contains('bread')) {
      return 'Grains';
    } else if (name.contains('oil') || name.contains('butter') || name.contains('salt') || name.contains('pepper')) {
      return 'Pantry';
    } else {
      return 'Other';
    }
  }
}