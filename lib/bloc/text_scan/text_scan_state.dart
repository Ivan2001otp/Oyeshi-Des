import 'package:equatable/equatable.dart';

abstract class TextScanState extends Equatable {
  const TextScanState();

  @override
  List<Object> get props => [];
}

class TextScanInitial extends TextScanState {
  const TextScanInitial();
}

class TextScanLoading extends TextScanState {
  final String? message;
  const TextScanLoading({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

// this is optional but will check it.
class IngredientsParsed extends TextScanState {
  final List<String> ingredients;
  final String originalText;
  
  const IngredientsParsed({
    required this.ingredients,
    required this.originalText,
  });
  
  @override
  List<Object> get props => [ingredients, originalText];
}

// OCR processing states.
class OcrProcessing extends TextScanState {
  final String? message;
  const OcrProcessing({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class OcrSuccess extends TextScanState {
  final String extractedText;
  final List<String> detectedText;

   const OcrSuccess({
    required this.extractedText,
    required this.detectedText,
  });
  
  @override
  List<Object> get props => [extractedText, detectedText];
}


class OcrError extends TextScanState {
  final String errorMessage;
  const OcrError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// when the image is captured and ready for OCR.
class ImageCaptured extends TextScanState {
  final String imagePath;

  const ImageCaptured({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

// handling camera states
class CameraReady extends TextScanState {
  final bool hasPermission;

  const CameraReady({required this.hasPermission});

  @override
  List<Object> get props => [hasPermission];
}

class CameraPermissionDenied extends TextScanState {
  const CameraPermissionDenied();
}

class CameraError extends TextScanState {
  final String errorMessage;

  const CameraError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
