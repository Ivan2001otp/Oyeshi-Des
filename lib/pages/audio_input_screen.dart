import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_bloc.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_event.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_state.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/pages/meal_planning_screen.dart';

class AudioInputScreen extends StatefulWidget {
  const AudioInputScreen({super.key});

  @override
  State<AudioInputScreen> createState() => _AudioInputScreenState();
}

class _AudioInputScreenState extends State<AudioInputScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Initialize audio input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioInputBloc>().add(const InitializeAudioInput());
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*title: const Text(
          'Oyeshi Des',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),*/
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: BlocConsumer<AudioInputBloc, AudioInputState>(
        listener: (context, state) {
          if (state is AudioInputListening) {
            _pulseController.repeat(reverse: true);
            _startRecordingTimer();
          } else {
            _pulseController.stop();
            _pulseController.reset();
            _stopRecordingTimer();
          }

          if (state is AudioInputCompleted) {
            _showIngredientsResult(
                context, state.parsedIngredients, state.finalText);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopSection(state),
                  Expanded(
                    child: _buildMiddleSection(state),
                  ),
                  _buildBottomSection(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection(AudioInputState state) {
    return Column(
      children: [
        const Text(
          'Voice Input',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getSubtitle(state),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildMiddleSection(AudioInputState state) {
    if (state is AudioInputLoading) {
      return Center(
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing speech recognition...'),
          ],
        ),
      );
    }

    if (state is AudioInputPermissionDenied) {
      return _buildPermissionDeniedWidget();
    }

    if (state is AudioInputError) {
      return _buildErrorWidget(state.message, showRetry: true);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildVoiceVisualization(state),
          if (state is AudioInputListening) ...[
            const SizedBox(height: 16),
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 32),
          _buildRecognizedText(state),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AudioInputState state) {
    if (state is AudioInputInitial || state is AudioInputLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state is! AudioInputPermissionDenied && state is! AudioInputError)
          _buildControlButtons(state),
        // const SizedBox(height: 6),
        // _buildHelpText(),
      ],
    );
  }

  Widget _buildVoiceVisualization(AudioInputState state) {
    final isListening = state is AudioInputListening;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening
                ? Colors.red.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            border: Border.all(
              color: isListening ? Colors.red : Colors.blue,
              width: 3,
            ),
          ),
          child: Transform.scale(
            scale: isListening ? _pulseAnimation.value : 1.0,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: 80,
              color: isListening ? Colors.red : Colors.blue,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecognizedText(AudioInputState state) {
    String text = '';
    List<String> partialResults = [];

    if (state is AudioInputListening) {
      text = state.recognizedText;
      partialResults = state.partialResults;
    } else if (state is AudioInputReady) {
      text = state.recognizedText;
      partialResults = state.partialResults;
    } else if (state is AudioInputCompleted) {
      text = state.finalText;
    }

    // Constrain the height to prevent overflow
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.3, // Maximum height to prevent screen overflow
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Current Recognition:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Constrain current text area
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 80, // Max height for current text
            ),
            child: Text(
              text.isEmpty ? 'Start speaking...' : text,
              style: TextStyle(
                fontSize: 16,
                color: text.isEmpty ? Colors.grey : Colors.black,
                height: 1.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),

          if (partialResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Individual Words:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            // Constrain the word list with scrollable container
            Container(
              constraints: BoxConstraints(maxHeight: 120, minHeight: 40),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: partialResults.map((result) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: Chip(
                        backgroundColor: Colors.green.shade300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        label: Text(
                          result,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtons(AudioInputState state) {
    final isListening = state is AudioInputListening;
    final hasText = state is AudioInputReady && state.recognizedText.isNotEmpty;
    final isCompleted = state is AudioInputCompleted;
    final isError = state is AudioInputError;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isListening && !isCompleted && !isError)
          ElevatedButton.icon(
            onPressed: () => _startListening(),
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (isListening)
          ElevatedButton.icon(
            onPressed: () => _confirmStopRecording(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (hasText && !isListening && !isError)
          ElevatedButton.icon(
            onPressed: () => _processText(state.recognizedText),
            icon: const Icon(Icons.check),
            label: const Text('Process Text'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (isCompleted)
          ElevatedButton.icon(
            onPressed: () => _resetRecording(),
            icon: const Icon(Icons.refresh),
            label: const Text('New Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (isError)
          ElevatedButton.icon(
            onPressed: () => _retry(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPermissionDeniedWidget() {
    return Column(
      children: [
        const Icon(
          Icons.mic_off,
          size: 100,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Microphone Permission Required',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Please grant microphone permission to use voice input',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _requestPermissions(),
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message, {bool showRetry = false}) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 100,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Something went wrong',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _retry(),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildHelpText() {
    return Column(
      children: [
        Text(
          '🎤 Troubleshooting:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '• Speak clearly and close to device\n• Minimize background noise\n• Ensure internet connection\n• Grant microphone permissions',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 12),
        Text(
          '💡 Each word appears individually in the list below',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getSubtitle(AudioInputState state) {
    if (state is AudioInputInitial) {
      return 'Tap the microphone to start recording';
    } else if (state is AudioInputLoading) {
      return 'Initializing voice recognition...';
    } else if (state is AudioInputListening) {
      return 'Listening continuously... Stop when you\'re done';
    } else if (state is AudioInputReady) {
      return 'Tap Start Recording to begin';
    } else if (state is AudioInputPermissionDenied) {
      return 'Microphone permission is required';
    } else if (state is AudioInputError) {
      return 'An error occurred';
    } else {
      return 'Voice input ready';
    }
  }

  void _startListening() {
    context.read<AudioInputBloc>().add(const StartListening());
  }

  void _stopListening() {
    context.read<AudioInputBloc>().add(const StopListening());
  }

  void _processText(String text) {
    context.read<AudioInputBloc>().add(ProcessAudioText(text));
  }

  void _requestPermissions() {
    context.read<AudioInputBloc>().add(const InitializeAudioInput());
  }

  void _retry() {
    context.read<AudioInputBloc>().add(const InitializeAudioInput());
  }

  void _resetRecording() {
    _stopRecordingTimer();
    _recordingDuration = Duration.zero;
    context.read<AudioInputBloc>().add(const ClearAudioInput());
  }

  void _confirmStopRecording() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Stop Recording'),
        content: const Text('Are you sure you want to stop recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _stopListening();
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showIngredientsResult(
    BuildContext context,
    List<Ingredient> ingredients,
    String originalText,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Found ${ingredients.length} Ingredients'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Original text:'),
              Text(
                originalText,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text('Parsed ingredients:'),
              const SizedBox(height: 8),
              ...ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ingredient.name)),
                        Chip(
                          label: Text(ingredient.category),
                          backgroundColor: Colors.blue.shade100,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetRecording();
            },
            child: const Text('Record Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(ingredients);

              // store in firebase.

              final parsedIngredients = ingredients
                  .map(
                    (ingredient) => Ingredient(
                        id: 'scan_${DateTime.now().millisecondsSinceEpoch}_${ingredients.indexOf(ingredient)}',
                        name: ingredient.name,
                        category: 'AudioText',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now()),
                  )
                  .toList();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MealPlanningScreen(
                    ingredients: parsedIngredients,
                  ),
                ),
              );
            },
            child: const Text('Use These Ingredients'),
          ),
        ],
      ),
    );
  }
}
