import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class AudioInputService {
  Future<bool> initialize();
  Future<bool> requestPermissions();
  Future<void> startListening(Function(String) onResult);
  Future<void> stopListening();
  Future<bool> get isAvailable;
  Stream<String> get recognizedWords;
}

class SpeechToTextService implements AudioInputService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  final _recognizedWordsController = StreamController<String>.broadcast();

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: ${error.errorMsg}');
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
      );
      return _isInitialized;
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final microphonePermission = await Permission.microphone.request();
      final speechPermission = await Permission.speech.request();
      
      return microphonePermission == PermissionStatus.granted ||
             speechPermission == PermissionStatus.granted;
    } catch (e) {
      print('Failed to request permissions: $e');
      return false;
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (!await isAvailable) {
      throw Exception('Speech recognition not available');
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            onResult(recognizedWords);
            _recognizedWordsController.add(recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
      );
    } catch (e) {
      throw Exception('Failed to start listening: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      print('Failed to stop listening: $e');
    }
  }

  @override
  Future<bool> get isAvailable async {
    return _isInitialized && _speechToText.isAvailable;
  }

  @override
  Stream<String> get recognizedWords => _recognizedWordsController.stream;

  void dispose() {
    _recognizedWordsController.close();
    _speechToText.stop();
  }
}