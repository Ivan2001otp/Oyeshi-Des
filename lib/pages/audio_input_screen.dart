import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_bloc.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_event.dart';
import 'package:oyeshi_des/bloc/audio_input/audio_input_state.dart';
import 'package:oyeshi_des/models/ingredient.dart';

class AudioInputScreen extends StatefulWidget {
  const AudioInputScreen({super.key});

  @override
  State<AudioInputScreen> createState() => _AudioInputScreenState();
}

class _AudioInputScreenState extends State<AudioInputScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: BlocConsumer<AudioInputBloc, AudioInputState>(
        listener: (context, state) {
          if (state is AudioInputListening) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }

          if (state is AudioInputCompleted) {
            _showIngredientsResult(context, state.parsedIngredients, state.finalText);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopSection(state),
                  _buildMiddleSection(state),
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(state),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMiddleSection(AudioInputState state) {
    if (state is AudioInputLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Processing...'),
        ],
      );
    }

    if (state is AudioInputPermissionDenied) {
      return _buildPermissionDeniedWidget();
    }

    if (state is AudioInputError) {
      return _buildErrorWidget(state.message);
    }

    return Column(
      children: [
        _buildVoiceVisualization(state),
        const SizedBox(height: 32),
        _buildRecognizedText(state),
      ],
    );
  }

  Widget _buildBottomSection(AudioInputState state) {
    if (state is AudioInputInitial || state is AudioInputLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (state is! AudioInputPermissionDenied && state is! AudioInputError)
          _buildControlButtons(state),
        const SizedBox(height: 16),
        _buildHelpText(),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recognized Text:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text.isEmpty ? 'Start speaking...' : text,
            style: TextStyle(
              fontSize: 16,
              color: text.isEmpty ? Colors.grey : Colors.black,
              height: 1.5,
            ),
          ),
          if (partialResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Partial Results:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: partialResults.map((result) {
                return Chip(
                  label: Text(
                    result,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isListening && !isCompleted)
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
            onPressed: () => _stopListening(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (hasText && !isListening)
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

  Widget _buildErrorWidget(String message) {
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
          '💡 Tip: Speak clearly and list ingredients one by one',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Example: "I have tomatoes, onions, chicken breast, and rice"',
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
      return 'Listening... Speak clearly';
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
    context.read<AudioInputBloc>().add(const ClearAudioInput());
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
                padding: const EdgeInsets.symmetric(vertical: 4),
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
            },
            child: const Text('Use These Ingredients'),
          ),
        ],
      ),
    );
  }
}