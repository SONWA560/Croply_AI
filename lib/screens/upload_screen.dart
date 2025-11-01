import 'package:croply_ai/screens/treatment_recommendations.dart';
import 'dart:io';
// import 'dart:convert'; // not used (kept for reference)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/inference_service.dart';
import '../services/treatment_recommendations.dart';
import '../models/model_type.dart';
import 'live_camera_screen.dart';
import '../widgets/custom_loader.dart';
import '../widgets/gradient_dialog.dart';

class ImageUploadPage extends StatefulWidget {
  final String serviceType;
  const ImageUploadPage({required this.serviceType, super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _imageFile;
  bool _isLoading = false;
  String? _resultText;

  // Pick image from device
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _resultText = null;
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get image: $e')),
      );
    }
  }

  // Upload to backend and process image
Future<void> _analyzeImage() async {
  if (_imageFile == null) return;

  setState(() => _isLoading = true);

  try {
    // Run local inference using the bundled TFLite models instead of uploading.
    final bytes = await _imageFile!.readAsBytes();

    // Map the selected service to a ModelType. Adjust matching to your app's labels.
    final lower = widget.serviceType.toLowerCase();
    ModelType modelType;
    if (lower.contains('pest')) {
      modelType = ModelType.pestDetection;
    } else if (lower.contains('growth') || lower.contains('stage')) {
      modelType = ModelType.growthStage;
    } else {
      modelType = ModelType.diseaseDetection;
    }

    final inference = await InferenceService.instance.predict(modelType, bytes);

    // Use higher threshold for Disease Detection (60%) since it lacks negative training examples
    // YOLO models can use lower threshold (40%) since they have more variety in training
    final double threshold = modelType == ModelType.diseaseDetection ? 0.60 : 0.40;
    
    // Debug: Log confidence value
    debugPrint('Detection: ${inference.label}');
    debugPrint('Confidence: ${(inference.confidence * 100).toStringAsFixed(2)}%');
    debugPrint('Threshold: ${(threshold * 100).toStringAsFixed(1)}%');

    // Check if confidence is too low (likely not a valid plant image)
    if (inference.confidence < threshold) {
      setState(() => _isLoading = false);
      debugPrint('Below threshold - showing warning dialog');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => GradientDialog(
            title: 'Low Confidence Detection',
            message:
              'The model detected "${inference.label}" with only ${(inference.confidence * 100).toStringAsFixed(1)}% confidence.\n\n'
              'This might not be a valid plant image. Please:\n\n'
              '• Ensure the image contains plants/crops\n'
              '• Improve lighting conditions\n'
              '• Get closer to the subject\n'
              '• Ensure the image is in focus',
            cancelText: 'Try Again',
            confirmText: 'Proceed Anyway',
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.pop(context);
              _proceedWithLowConfidence(inference, modelType);
            },
          ),
        );
      }
      return;
    }

    debugPrint('Above threshold - proceeding to results');
    _navigateToResults(inference, modelType);
  } catch (e, st) {
    debugPrint(' Local inference error: $e\n$st');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during local inference: $e')),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

void _proceedWithLowConfidence(inference, ModelType modelType) {
  _navigateToResults(inference, modelType);
}

void _navigateToResults(inference, ModelType modelType) {
  final detectedLabel = inference.label;
  final confidence = 'Confidence: ${(inference.confidence * 100).toStringAsFixed(1)}%';
  final treatment = TreatmentRecommendations.getRecommendation(detectedLabel, modelType);
  final fullRecommendation = '$confidence\n\n$treatment';

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreatmentRecommendationsPage(
        disease: detectedLabel,
        recommendation: fullRecommendation,
        modelType: modelType,
        imageFile: _imageFile!,
        confidence: inference.confidence,
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final bool isMobile = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('Upload - ${widget.serviceType}'),
        backgroundColor: const Color(0xFF0F4B06),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _UploadBox(
              icon: Icons.cloud_upload,
              title: 'Upload from Device',
              subtitle: 'Tap to browse your files',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 24),
            if (isMobile)
              _UploadBox(
                icon: Icons.photo_camera,
                title: 'Capture with Camera',
                subtitle: 'Tap to open your camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            const SizedBox(height: 24),
            if (isMobile)
              _UploadBox(
                icon: Icons.videocam,
                title: 'Live Camera Detection',
                subtitle: 'Real-time analysis with bounding boxes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveCameraScreen(
                        serviceType: widget.serviceType,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 30),
            if (_imageFile != null)
              Column(
                children: [
                  Image.file(_imageFile!, height: 250),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Column(
                          children: [
                            CustomLoader(size: 100),
                            SizedBox(height: 16),
                            Text(
                              'Analyzing image...',
                              style: TextStyle(
                                color: Color(0xFF0F4B06),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _analyzeImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4B06),
                            foregroundColor: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: const Text(
                            'Analyze Image',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 20),
                  if (_resultText != null)
                    const Text(
                      'Result:\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F4B06),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (_resultText != null)
                    Text(
                      _resultText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F4B06),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(top: BorderSide(color: Color(0xFF0F4B06))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Home',
              color: const Color(0xFF0F4B06),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            _NavItem(
              icon: Icons.grass,
              label: 'My Crops',
              color: const Color(0xFF15500D),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/my_crops'),
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'Settings',
              color: const Color(0xFF15500D),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// Upload Box Component
class _UploadBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double boxHeight = MediaQuery.of(context).size.height * 0.25;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: boxHeight.clamp(180, 250),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: const Color(0xFF0F4B06)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFEFEFE),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF0F4B06)),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF0F4B06))),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF15500D))),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom NavBar Item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
