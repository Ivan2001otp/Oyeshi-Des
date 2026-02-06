import 'package:equatable/equatable.dart';

abstract class TextScanEvent extends Equatable {
  const TextScanEvent();

  @override
  List<Object> get props => [];
}

class InitializeCamera extends TextScanEvent {
  const InitializeCamera();
}


// Request camera permission from user
class RequestCameraPermission extends TextScanEvent {
  const RequestCameraPermission();
}

// Capture photo from camera
class CaptureImage extends TextScanEvent {
  const CaptureImage();
}

// Retry capture after error or cancel
class RetryCapture extends TextScanEvent {
  const RetryCapture();
}

// Use image from gallery instead of camera
class PickImageFromGallery extends TextScanEvent {
  const PickImageFromGallery();
}


// Process captured image with OCR
class ProcessImage extends TextScanEvent {
  final String imagePath;
  
  const ProcessImage(this.imagePath);
  
  @override
  List<Object> get props => [imagePath];
}

// Cancel OCR processing
class CancelProcessing extends TextScanEvent {
  const CancelProcessing();
}


// Parse ingredients from OCR extracted text
class ParseIngredients extends TextScanEvent {
  final String extractedText;
  
  const ParseIngredients(this.extractedText);
  
  @override
  List<Object> get props => [extractedText];
}

// Manually edit the extracted text before parsing
class EditExtractedText extends TextScanEvent {
  final String editedText;
  
  const EditExtractedText(this.editedText);
  
  @override
  List<Object> get props => [editedText];
}


// Switch between front/back camera
class SwitchCamera extends TextScanEvent {
  const SwitchCamera();
}

// Toggle camera flash
class ToggleFlash extends TextScanEvent {
  const ToggleFlash();
}

// Zoom camera
class ZoomCamera extends TextScanEvent {
  final double zoomLevel;
  
  const ZoomCamera(this.zoomLevel);
  
  @override
  List<Object> get props => [zoomLevel];
}

// Reset the entire scanning process
class ResetScan extends TextScanEvent {
  const ResetScan();
}

// Clear any errors and try again
class ClearError extends TextScanEvent {
  const ClearError();
}