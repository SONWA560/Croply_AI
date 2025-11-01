import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/inference_service.dart';
import '../models/model_type.dart';
import '../models/inference_result.dart';

class LiveCameraScreen extends StatefulWidget {
  final String serviceType;
  const LiveCameraScreen({required this.serviceType, super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  InferenceResult? _latestResult;
  bool _isInitializing = true;
  String? _error;
  Timer? _inferenceTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No cameras available';
          _isInitializing = false;
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });

      // Start periodic inference (every 500ms to avoid overwhelming the model)
      _inferenceTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _runInference();
      });
    } catch (e) {
      setState(() {
        _error = 'Camera initialization failed: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _runInference() async {
    if (_isDetecting || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _isDetecting = true;

    try {
      // Use streaming image instead of takePicture for true live inference
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      // Get model type from service type
      ModelType modelType;
      if (widget.serviceType.toLowerCase().contains('pest')) {
        modelType = ModelType.pestDetection;
      } else if (widget.serviceType.toLowerCase().contains('growth') || 
                 widget.serviceType.toLowerCase().contains('stage')) {
        modelType = ModelType.growthStage;
      } else {
        modelType = ModelType.diseaseDetection;
      }

      final result = await InferenceService.instance.predict(modelType, bytes);

      // Use higher threshold for Disease Detection (needs 60% min due to no negative class)
      // YOLO models can use 40% since they were trained with more variety
      final double threshold = modelType == ModelType.diseaseDetection ? 0.60 : 0.40;
      
      // Only update if confidence is above threshold
      // This prevents false positives on random objects
      if (mounted) {
        if (result.confidence >= threshold) {
          setState(() {
            _latestResult = result;
          });
        } else {
          // Clear result if confidence drops below threshold
          setState(() {
            _latestResult = null;
          });
        }
      }
    } catch (e) {
      if (e.toString().contains('disposed')) {
        // Camera was disposed, stop trying to run inference
        _inferenceTimer?.cancel();
        return;
      }
      debugPrint('Inference error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _inferenceTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Live ${_getServiceName()} Detection'),
        backgroundColor: Colors.black87,
      ),
      body: _buildBody(),
    );
  }

  String _getServiceName() {
    if (widget.serviceType.toLowerCase().contains('pest')) {
      return 'Pest';
    } else if (widget.serviceType.toLowerCase().contains('growth') || 
               widget.serviceType.toLowerCase().contains('stage')) {
      return 'Growth Stage';
    } else {
      return 'Disease';
    }
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Detection overlay with bounding box
        if (_latestResult != null)
          Positioned.fill(
            child: CustomPaint(
              painter: DetectionPainter(
                result: _latestResult!,
                modelType: _getModelType(),
              ),
            ),
          ),
        
        // Detection info panel at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildDetectionPanel(),
        ),
      ],
    );
  }

  ModelType _getModelType() {
    if (widget.serviceType.toLowerCase().contains('pest')) {
      return ModelType.pestDetection;
    } else if (widget.serviceType.toLowerCase().contains('growth') || 
               widget.serviceType.toLowerCase().contains('stage')) {
      return ModelType.growthStage;
    } else {
      return ModelType.diseaseDetection;
    }
  }

  Widget _buildDetectionPanel() {
    if (_latestResult == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Point camera at plants...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Detection requires 40%+ confidence',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final confidencePercent = (_latestResult!.confidence * 100).toStringAsFixed(1);
    final confidenceColor = _latestResult!.confidence >= 0.6
        ? Colors.green
        : _latestResult!.confidence >= 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: confidenceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$confidencePercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _latestResult!.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Inference: ${_latestResult!.inferenceTimeMs}ms',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class DetectionPainter extends CustomPainter {
  final InferenceResult result;
  final ModelType modelType;

  DetectionPainter({required this.result, required this.modelType});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a centered bounding box
    final confidenceColor = result.confidence >= 0.6
        ? Colors.green
        : result.confidence >= 0.3
            ? Colors.orange
            : Colors.red;

    final paint = Paint()
      ..color = confidenceColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final fillPaint = Paint()
      ..color = confidenceColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create a centered box (60% of screen size)
    final boxWidth = size.width * 0.7;
    final boxHeight = size.height * 0.5;
    final left = (size.width - boxWidth) / 2;
    final top = (size.height - boxHeight) / 2;

    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    
    // Draw filled background
    canvas.drawRect(rect, fillPaint);
    
    // Draw border
    canvas.drawRect(rect, paint);

    // Draw corner brackets (more stylish)
    final bracketPaint = Paint()
      ..color = confidenceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const bracketLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + boxWidth - bracketLength, top),
      Offset(left + boxWidth, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + boxWidth, top),
      Offset(left + boxWidth, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + boxHeight - bracketLength),
      Offset(left, top + boxHeight),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + boxHeight),
      Offset(left + bracketLength, top + boxHeight),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + boxWidth - bracketLength, top + boxHeight),
      Offset(left + boxWidth, top + boxHeight),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + boxWidth, top + boxHeight - bracketLength),
      Offset(left + boxWidth, top + boxHeight),
      bracketPaint,
    );

    // Draw scanning line animation effect
    final scanLinePaint = Paint()
      ..color = confidenceColor.withOpacity(0.5)
      ..strokeWidth = 2.0;

    final scanY = top + (boxHeight * ((DateTime.now().millisecondsSinceEpoch % 2000) / 2000));
    canvas.drawLine(
      Offset(left, scanY),
      Offset(left + boxWidth, scanY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
