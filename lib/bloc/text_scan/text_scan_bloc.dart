import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oyeshi_des/services/ai_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'text_scan_event.dart';
import 'text_scan_state.dart';

class TextScanBloc extends Bloc<TextScanEvent, TextScanState> {
  CameraController? _cameraController;
  final AIService _aiService;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;
  CameraLensDirection _currentLens = CameraLensDirection.back;

  CameraController? get cameraController => _cameraController;

  TextScanBloc({required AIService aiService})
      : _aiService = aiService,
        super(const TextScanInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<RequestCameraPermission>(_onRequestCameraPermission);
    on<CaptureImage>(_onCaptureImage);
    on<ProcessImage>(_onProcessImage);
    on<ParseIngredients>(_onParseIngredients);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleFlash>(_onToggleFlash);
    on<RetryCapture>(_onRetryCapture);
    on<PickImageFromGallery>(_onPickImageFromGallery);
    on<EditExtractedText>(_onEditExtractedText);
    on<ResetScan>(_onResetScan);
    on<ClearError>(_onClearError);
    on<CancelProcessing>(_onCancelProcessing);
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    return super.close();
  }

// other event handlers.
  Future<void> _onRetryCapture(
    RetryCapture event,
    Emitter<TextScanState> emit,
  ) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      emit(CameraReady(hasPermission: true));
    } else {
      add(const InitializeCamera());
    }
  }

  Future<void> _onPickImageFromGallery(
    PickImageFromGallery event,
    Emitter<TextScanState> emit,
  ) async {
    emit(const TextScanLoading(message: 'Picking image from gallery...'));

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Optimize for OCR
        maxHeight: 1080,
        imageQuality: 85,
    );
    
    if (pickedFile == null) {
      emit(const CameraError(errorMessage: 'No image selected'));
      return;
    }
    
    emit(ImageCaptured(imagePath:  pickedFile.path));
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      emit(CameraError(errorMessage: 'Failed to pick image: ${e.toString()}'));
    }
  }

  void _onEditExtractedText(
    EditExtractedText event,
    Emitter<TextScanState> emit,
  ) {
    // For now, just re-parse with edited text
    add(ParseIngredients(event.editedText));
  }

  void _onResetScan(
    ResetScan event,
    Emitter<TextScanState> emit,
  ) {
    // If camera was initialized, go back to camera ready
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      emit(CameraReady(hasPermission: true));
    } else {
      emit(const TextScanInitial());
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<TextScanState> emit,
  ) {
    // Go back to previous safe state
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      emit(CameraReady(hasPermission: true));
    } else {
      emit(const TextScanInitial());
    }
  }

  void _onCancelProcessing(
    CancelProcessing event,
    Emitter<TextScanState> emit,
  ) {
    // Go back to capture state
    if (state is ImageCaptured) {
      emit(CameraReady(hasPermission: true));
    }
  }

// camera control handlers
  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<TextScanState> emit,
  ) async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      _currentLens = _currentLens == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final camera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == _currentLens,
        orElse: () => _cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
        ),
      );

      await _cameraController?.dispose();

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      emit(CameraReady(hasPermission: true));
    } catch (e) {
      debugPrint('Camera switch error: $e');
      // Don't emit error - keep current camera
    }
  }

  Future<void> _onToggleFlash(
    ToggleFlash event,
    Emitter<TextScanState> emit,
  ) async {
    if (_cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  // Parse ingredients from extracted text.(optional)
  Future<void> _onParseIngredients(
    ParseIngredients event,
    Emitter<TextScanState> emit,
  ) async {
    emit(const TextScanLoading(message: 'Parsing ingredients...'));

    try {
      final ingredients = await _aiService.parseIngredientsFromText(
        event.extractedText,
      );

      if (ingredients.isEmpty) {
        emit(OcrError('No ingredients detected in text'));
        return;
      }

      emit(IngredientsParsed(
        ingredients: ingredients,
        originalText: event.extractedText,
      ));
    } catch (e) {
      debugPrint('Ingredient parsing error: $e');
      emit(OcrError('Failed to parse ingredients: ${e.toString()}'));
    }
  }

  // process image with ocr.
  Future<void> _onProcessImage(
    ProcessImage event,
    Emitter<TextScanState> emit,
  ) async {
    emit(const OcrProcessing());

    try {
      final imageFile = File(event.imagePath);
      if (!await imageFile.exists()) {
        emit(const OcrError('Image file not found'));
        return;
      }

      // Initialize text recognizer
      final textRecognizer = TextRecognizer();

      // Process image
      final inputImage = InputImage.fromFilePath(event.imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Clean up recognizer
      textRecognizer.close();

      final extractedText = recognizedText.text;
      final detectedLines = recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text)
          .where((text) => text.trim().isNotEmpty)
          .toList();

      if (extractedText.trim().isEmpty) {
        emit(const OcrError('No text found in image'));
        return;
      }

      emit(
        OcrSuccess(detectedText: detectedLines, extractedText: extractedText),
      );
    } catch (e) {
      debugPrint('OCR processing error: $e');
      emit(OcrError('OCR failed: ${e.toString()}'));
    }
  }

  // capture image handler
  Future<void> _onCaptureImage(
      CaptureImage event, Emitter<TextScanState> emit) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      emit(CameraError(errorMessage: 'Camera not ready'));
      return;
    }

    emit(const TextScanLoading(message: 'Capturing image...'));

    try {
      final image = await _cameraController!.takePicture();
      emit(ImageCaptured(imagePath: image.path));
    } catch (e) {
      debugPrint('Image capture error: $e');
      emit(CameraError(
          errorMessage: 'Failed to capture image: ${e.toString()}'));
    }
  }

  Future<void> _onInitializeCamera(
      InitializeCamera event, Emitter<TextScanState> emit) async {
    emit(const TextScanLoading(message: "Initializing Camera..."));

    try {
      final permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        emit(const CameraPermissionDenied());
        return;
      }

      // get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        emit(const CameraError(errorMessage: "No cameras found on device."));
        return;
      }

      final camera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // initialize camera controller.
      _cameraController =
          CameraController(camera, ResolutionPreset.high, enableAudio: false);

      await _cameraController!.initialize();

      emit(CameraReady(hasPermission: true));
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      emit(CameraError(
          errorMessage: 'Failed to initialize camera: ${e.toString()}'));
    }
  }

  Future<void> _onRequestCameraPermission(
      RequestCameraPermission event, Emitter<TextScanState> emit) async {
    emit(const TextScanLoading(message: 'Requesting permission...'));

    try {
      final permissionStatus = await Permission.camera.request();

      if (permissionStatus.isGranted) {
        add(const InitializeCamera());
      } else {
        emit(const CameraPermissionDenied());
      }
    } catch (e) {
      emit(CameraError(
          errorMessage: 'Permission request failed: ${e.toString()}'));
    }
  }
}
