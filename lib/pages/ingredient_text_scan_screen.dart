import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:oyeshi_des/constants/fonts.dart';
import 'package:oyeshi_des/models/ingredient.dart';
import 'package:oyeshi_des/pages/meal_planning_screen.dart';

import '../bloc/text_scan/text_scan_bloc.dart';
import '../bloc/text_scan/text_scan_event.dart';
import '../bloc/text_scan/text_scan_state.dart';
import '../services/ai_service.dart';

class IngredientTextScanScreen extends StatefulWidget {
  const IngredientTextScanScreen({super.key});

  @override
  State<IngredientTextScanScreen> createState() =>
      _IngredientTextScanScreenState();
}

class _IngredientTextScanScreenState extends State<IngredientTextScanScreen> {
  TextScanBloc? _textScanBloc;

  @override
  void initState() {
    super.initState();
    _textScanBloc = TextScanBloc(
      aiService:
          context.read<AIService>(), // Assuming AIService is provided above
    )..add(const InitializeCamera());
  }

  @override
  void dispose() {
    _textScanBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _textScanBloc!,
      child: Scaffold(
     
        body: BlocConsumer<TextScanBloc, TextScanState>(
          listener: (context, state) {
            _handleStateChanges(context, state);
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, TextScanState state) {
    if (state is ImageCaptured) {
      // Automatically process the captured image
      context.read<TextScanBloc>().add(ProcessImage(state.imagePath));
    } else if (state is OcrSuccess) {
      // Automatically parse ingredients from OCR text
      context.read<TextScanBloc>().add(ParseIngredients(state.extractedText));
    } else if (state is IngredientsParsed) {
      // Show results dialog
      _showIngredientsResult(context, state.ingredients, state.originalText);
    }
  }

  Widget _buildBody(BuildContext context, TextScanState state) {
    if (state is TextScanLoading) {
      return _buildLoadingState(state.message ?? 'Loading...');
    } else if (state is CameraPermissionDenied) {
      return _buildPermissionDeniedState(context);
    } else if (state is CameraError) {
      return _buildErrorState(context, state.errorMessage, showRetry: true);
    } else if (state is CameraReady) {
      return _buildCameraView(context);
    } else if (state is ImageCaptured) {
      return _buildImagePreview(context, state.imagePath);
    } else if (state is OcrProcessing) {
      return _buildProcessingState('Processing image with OCR...');
    } else if (state is OcrError) {
      return _buildErrorState(context, state.errorMessage, showRetry: true);
    } else if (state is OcrSuccess) {
      return _buildOcrResult(context, state);
    } else if (state is TextScanInitial) {
      return _buildLoadingState('Initializing...');
    } else {
      return _buildLoadingState('Preparing...');
    }
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: FontConstants.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontConstants.fontFamily),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Please grant camera permission to scan handwritten ingredient lists',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: FontConstants.fontFamily),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context
                    .read<TextScanBloc>()
                    .add(const RequestCameraPermission());
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(fontFamily: FontConstants.fontFamily),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(fontFamily: FontConstants.fontFamily),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error,
      {bool showRetry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontConstants.fontFamily),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: FontConstants.fontFamily),
            ),
            const SizedBox(height: 30),
            if (showRetry)
              ElevatedButton(
                onPressed: () {
                  context.read<TextScanBloc>().add(const RetryCapture());
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontFamily: FontConstants.fontFamily),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(fontFamily: FontConstants.fontFamily),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context) {
    return BlocBuilder<TextScanBloc, TextScanState>(
      builder: (context, state) {
        final scanBloc = context.read<TextScanBloc>();
        return Stack(
          children: [
            // Camera preview
            SizedBox.expand(
              child: CameraPreview(scanBloc.cameraController!),
            ),
            // Camera overlay with guide
            _buildCameraOverlay(),

            // Bottom controls
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildCameraControls(context),
            ),

            // Top controls
            Positioned(
              top: 44,
              right: 20,
              child: _buildTopControls(context),
            ),

            // Instructions
            Positioned(
              top: 44,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 How to scan:',
                      style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Place handwritten list\n2. Ensure good lighting\n3. Hold steady\n4. Tap capture button',
                      style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          color: Colors.white,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCameraOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.15),
          width: MediaQuery.of(context).size.width * 0.94,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Align list within frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, 
                fontFamily: FontConstants.fontFamily,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 40,
        children: [
          // Gallery button
          IconButton(
            onPressed: () {
              context.read<TextScanBloc>().add(const PickImageFromGallery());
            },
            icon: const Icon(Icons.photo_library,
                size: 32, color: Colors.deepOrange),
            tooltip: 'Pick from gallery',
            style: IconButton.styleFrom(
              side: BorderSide(color: Colors.black, width: 3),
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(12),
            ),
          ),

          // Capture button
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: IconButton(
              onPressed: () {
                context.read<TextScanBloc>().add(const CaptureImage());
              },
              icon: const Icon(Icons.camera_alt_outlined,
                  size: 36, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 40, 176),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),

          // Flash toggle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: IconButton(
              onPressed: () {
                context.read<TextScanBloc>().add(const ToggleFlash());
              },
              icon: const Icon(Icons.flash_on, size: 32, color: Colors.white),
              tooltip: 'Toggle flash',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Row(
      children: [
        // Switch camera
        /*IconButton(
          onPressed: () {
            context.read<TextScanBloc>().add(const SwitchCamera());
          },
          icon: const Icon(Icons.cameraswitch, size: 28, color: Colors.white),
          tooltip: 'Switch camera',
        ),
        const SizedBox(width: 16),
        */
        // Close button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 28, color: Colors.white),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, String imagePath) {
    return Stack(
      children: [
        // Image preview
        Center(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),

        // Processing overlay
        Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Processing image...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: FontConstants.fontFamily,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<TextScanBloc>()
                            .add(const CancelProcessing());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontFamily: FontConstants.fontFamily),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TextScanBloc>().add(const RetryCapture());
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: FontConstants.fontFamily),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<TextScanBloc>().add(const CancelProcessing());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: FontConstants.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrResult(BuildContext context, OcrSuccess state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Extracted Text',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: FontConstants.fontFamily),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.extractedText,
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: FontConstants.fontFamily),
                    ),
                    const SizedBox(height: 20),
                    if (state.detectedText.isNotEmpty) ...[
                      const Text(
                        'Detected lines:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontFamily: FontConstants.fontFamily),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.detectedText.map((line) {
                          return Chip(
                            label: Text(
                              line,
                              style: TextStyle(
                                  fontFamily: FontConstants.fontFamily),
                            ),
                            backgroundColor: Colors.blue.shade100,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<TextScanBloc>()
                        .add(EditExtractedText(state.extractedText));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Edit Text',
                    style: TextStyle(fontFamily: FontConstants.fontFamily),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<TextScanBloc>()
                        .add(ParseIngredients(state.extractedText));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Parse Ingredients',
                    style: TextStyle(fontFamily: FontConstants.fontFamily),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIngredientsResult(
      BuildContext context, List<String> ingredients, String originalText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Found Ingredients',
          style: TextStyle(fontFamily: FontConstants.fontFamily),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Original text:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: FontConstants.fontFamily)),
              Text(
                originalText,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    fontFamily: FontConstants.fontFamily),
              ),
              const SizedBox(height: 16),
              const Text(
                'Parsed ingredients:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: FontConstants.fontFamily),
              ),
              const SizedBox(height: 8),
              ...ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ingredient)),
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
              context.read<TextScanBloc>().add(const RetryCapture());
            },
            child: const Text(
              'Scan Again',
              style: TextStyle(fontFamily: FontConstants.fontFamily),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();

              final parsedIngredients = ingredients
                  .map((name) => Ingredient(
                        id: 'scan_${DateTime.now().millisecondsSinceEpoch}_${ingredients.indexOf(name)}',
                        name: name,
                        category: 'Scanned',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ))
                  .toList();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      MealPlanningScreen(ingredients: parsedIngredients),
                ),
              );
            },
            child: const Text(
              'Use These Ingredients',
              style: TextStyle(fontFamily: FontConstants.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
