import 'package:equatable/equatable.dart';

abstract class AudioInputEvent extends Equatable {
  const AudioInputEvent();

  @override
  List<Object> get props => [];
}

class InitializeAudioInput extends AudioInputEvent {
  const InitializeAudioInput();
}

class StartListening extends AudioInputEvent {
  const StartListening();
}

class StopListening extends AudioInputEvent {
  const StopListening();
}

class AudioRecognized extends AudioInputEvent {
  final String recognizedText;

  const AudioRecognized(this.recognizedText);

  @override
  List<Object> get props => [recognizedText];
}

class ProcessAudioText extends AudioInputEvent {
  final String audioText;

  const ProcessAudioText(this.audioText);

  @override
  List<Object> get props => [audioText];
}

class ClearAudioInput extends AudioInputEvent {
  const ClearAudioInput();
}