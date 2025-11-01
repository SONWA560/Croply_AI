// dart:ui not needed here
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

import '../models/model_type.dart';
import '../models/inference_result.dart';

class InferenceService {
  InferenceService._();
  static final InferenceService instance = InferenceService._();

  final Map<ModelType, Interpreter> _interpreters = {};
  final Map<ModelType, List<String>> _labels = {}; // optional if you have label files

  Future<void> preload(ModelType type) async {
    if (_interpreters.containsKey(type)) return;
    final interpreter = await Interpreter.fromAsset(type.modelAsset);
    _interpreters[type] = interpreter;
    // optionally load label file: try same folder with .txt
    try {
      final labelAsset = type.modelAsset.replaceAll('.tflite', '_labels.txt');
      final labelStr = await rootBundle.loadString(labelAsset);
      _labels[type] = labelStr.split('\n').where((l) => l.trim().isNotEmpty).toList();
    } catch (e) {
      // no labels available — OK
    }
  }

  Future<void> disposeAll() async {
    for (final it in _interpreters.values) {
      it.close();
    }
    _interpreters.clear();
    _labels.clear();
  }

  Future<InferenceResult> predict(ModelType type, Uint8List imageBytes) async {
    await preload(type);
    final interpreter = _interpreters[type]!;
    final inputTensorInfo = interpreter.getInputTensors()[0];
    final inputShape = inputTensorInfo.shape; // e.g. [1,224,224,3]
    
    // Check actual tensor type instead of relying on filename
    final inputType = inputTensorInfo.type;
    final String typeStr = inputType.toString().toLowerCase();
    final bool isActuallyQuantized = typeStr.contains('uint8') || typeStr.contains('int8');
    
    debugPrint('Model: ${type.displayName}');
    debugPrint('   Input shape: $inputShape');
    debugPrint('   Input type: $inputType');
    debugPrint('   Quantized: $isActuallyQuantized');

    // Determine model input size and channels
    int height = 224, width = 224, channels = 3;
    if (inputShape.length >= 4) {
      height = inputShape[1];
      width = inputShape[2];
      channels = inputShape[3];
    } else if (inputShape.length == 2) {
      // flatten 1D input
      height = inputShape[1];
      width = 1;
      channels = 1;
    }

    // Preprocess on background isolate
    final bool isQuantized = isActuallyQuantized;
    // Disease Detection model (MobileNetV3) has Rescaling layer built-in - needs [0, 255] input
    final bool hasBuiltInRescaling = type == ModelType.diseaseDetection;
    
    final preprocessPayload = _PreprocessPayload(
      bytes: imageBytes,
      targetWidth: width,
      targetHeight: height,
      channels: channels,
      isQuantized: isQuantized,
      hasBuiltInRescaling: hasBuiltInRescaling,
    );
    final preprocessed = await compute<_PreprocessPayload, _PreprocessedResult>(
      _preprocess,
      preprocessPayload,
    );

  // Run inference on main isolate (interpreter.run is fast but keep heavy ops off UI)
    final stopwatch = Stopwatch()..start();
    // Prepare output buffer: infer output shape
    final outputTensors = interpreter.getOutputTensors();
    // assume single output tensor with shape [1, N] or [N] or [1, classes, boxes] for detection
    final outShape = outputTensors[0].shape;
    
    // Build output buffer matching the exact shape the model expects
    final dynamic outputBuffer;
    final bool isDetectionModel = outShape.length == 3; // YOLO format: [1, classes, boxes]
    
    if (isDetectionModel) {
      // Detection model: [1, num_classes, num_boxes]
      final int numClasses = outShape[1];
      final int numBoxes = outShape[2];
      outputBuffer = List.generate(1, (_) => 
        List.generate(numClasses, (_) => 
          List<double>.filled(numBoxes, 0.0)
        )
      );
    } else if (outShape.length == 2 && outShape[0] == 1) {
      // Classification: [1, N] - create nested list
      final int numClasses = outShape[1];
      outputBuffer = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));
    } else if (outShape.length == 1) {
      // Classification: [N] - create flat list
      outputBuffer = List<double>.filled(outShape[0], 0.0);
    } else {
      // Fallback: flatten all dimensions
      final outLength = outShape.fold(1, (p, e) => p * e);
      outputBuffer = List<double>.filled(outLength, 0.0);
    }

    try {
      debugPrint('Running inference...');
      debugPrint('   Input shape: ${preprocessed.input.runtimeType}');
      debugPrint('   Output buffer shape: ${outputBuffer.runtimeType}');
      
      interpreter.run(preprocessed.input, outputBuffer);
      
      debugPrint('Inference completed');
      
      // For disease detection, show full output to diagnose if it's stuck
      if (type == ModelType.diseaseDetection) {
        debugPrint('   Full output buffer type: ${outputBuffer.runtimeType}');
        if (outputBuffer is List<List<double>>) {
          debugPrint('   Output values: ${outputBuffer[0]}');
        } else if (outputBuffer is List<double>) {
          debugPrint('   Output values: $outputBuffer');
        }
      } else {
        debugPrint('   Output sample: ${outputBuffer.toString().substring(0, math.min(100, outputBuffer.toString().length))}...');
      }
    } catch (e) {
      debugPrint(' Inference error: $e');
      // fallback: try different shapes if model expects different arrangement
      rethrow;
    }
    stopwatch.stop();

    // Postprocess: extract scores
    final List<double> scores;
    if (isDetectionModel) {
      // For Ultralytics YOLO: [1, num_outputs, 8400]
      // num_outputs = 4 (bbox coords) + num_classes
      // We need to extract class scores from the output
      final List<List<double>> detections = (outputBuffer as List)[0] as List<List<double>>;
      final int numOutputs = detections.length; // e.g., 10 for pest (4 + 6 classes)
      final int numBoxes = detections[0].length; // 8400
      
      // Extract class scores (skip first 4 rows which are bbox coords)
      final int numClasses = numOutputs - 4;
      scores = List<double>.filled(numClasses, 0.0);
      
      // For each class, find the maximum confidence across all 8400 detection boxes
      for (int classIdx = 0; classIdx < numClasses; classIdx++) {
        final List<double> classScores = detections[4 + classIdx]; // Skip bbox coords (0-3)
        double maxScore = classScores.reduce((a, b) => a > b ? a : b);
        
        // For quantized int8 YOLO models, normalize scores from 0-255 to 0-1
        if (isQuantized) {
          maxScore = maxScore / 255.0;
        }
        
        scores[classIdx] = maxScore;
      }
      
      debugPrint(' YOLO output: $numOutputs outputs ($numClasses classes + 4 bbox), $numBoxes boxes');
    } else if (outputBuffer is List<List<double>>) {
      // Classification: flatten [1, N] to [N]
      scores = outputBuffer[0];
    } else if (outputBuffer is List<double>) {
      scores = outputBuffer;
    } else {
      scores = List<double>.from(outputBuffer);
    }

    // Check if scores are already probabilities (sum close to 1.0) or logits
    final double scoresSum = scores.fold(0.0, (a, b) => a + b);
    final double maxScore = scores.reduce((a, b) => a > b ? a : b);
    
    // Heuristic: If max score is between 0-1 and scores look bounded, likely already probabilities
    // If scores are large (>10) or very negative, they're logits
    final bool scoresAreProbabilities = (scoresSum - 1.0).abs() < 0.1 || // Sum is ~1.0
                                        (maxScore < 1.0 && scoresSum < 2.0); // Bounded in [0,1] range
    
    // YOLO outputs probabilities, some classification models output probabilities, others output logits
    final bool shouldApplySoftmax = !isDetectionModel && !scoresAreProbabilities;
    final probs = shouldApplySoftmax ? _softmax(scores) : scores;

    // Debug: Check raw scores and probabilities
    debugPrint(' Raw scores (first 5): ${scores.take(math.min(5, scores.length)).map((s) => s.toStringAsFixed(4)).toList()}');
    debugPrint(' Raw scores sum: ${scoresSum.toStringAsFixed(4)} (probabilities: $scoresAreProbabilities)');
    debugPrint(' Final probs (first 5): ${probs.take(math.min(5, probs.length)).map((p) => (p * 100).toStringAsFixed(2)).toList()}%');
    debugPrint(' Max probability: ${(probs.reduce((a, b) => a > b ? a : b) * 100).toStringAsFixed(2)}%');
    debugPrint(' Is detection model: $isDetectionModel, Softmax applied: $shouldApplySoftmax');

    // Pick top prediction
    final topIdx = probs.indexWhere((p) => p == probs.reduce((a, b) => a > b ? a : b));
    final label = (_labels.containsKey(type) && topIdx < _labels[type]!.length)
        ? _labels[type]![topIdx]
        : 'label_$topIdx';
    final confidence = probs[topIdx];

    return InferenceResult(
      label: label,
      confidence: confidence,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
      modelType: type,
    );
  }
}

/// Preprocessing payload/result used with compute()
class _PreprocessPayload {
  final Uint8List bytes;
  final int targetWidth;
  final int targetHeight;
  final int channels;
  final bool isQuantized;
  final bool hasBuiltInRescaling;

  _PreprocessPayload({
    required this.bytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.channels,
    required this.isQuantized,
    required this.hasBuiltInRescaling,
  });
}

class _PreprocessedResult {
  final Object input; // nested List shaped as [1, h, w, c]
  _PreprocessedResult(this.input);
}

_PreprocessedResult _preprocess(_PreprocessPayload p) {
  final img.Image? image = img.decodeImage(p.bytes);
  if (image == null) throw Exception('Could not decode image');
  
  // For YOLO models (640x640), use letterbox padding to preserve aspect ratio
  // For MobileNet/classification models (224x224), use resize without crop for better accuracy
  final img.Image resized;
  if (p.targetWidth == 640 && p.targetHeight == 640) {
    // YOLO letterbox preprocessing
    final double scale = math.min(
      p.targetWidth / image.width,
      p.targetHeight / image.height,
    );
    final int newWidth = (image.width * scale).round();
    final int newHeight = (image.height * scale).round();
    
    // Resize maintaining aspect ratio
    final img.Image scaled = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
    
    // Create 640x640 canvas with gray padding
    resized = img.Image(width: p.targetWidth, height: p.targetHeight);
    img.fill(resized, color: img.ColorRgb8(114, 114, 114)); // Gray padding
    
    // Paste scaled image in center
    final int offsetX = ((p.targetWidth - newWidth) / 2).round();
    final int offsetY = ((p.targetHeight - newHeight) / 2).round();
    img.compositeImage(resized, scaled, dstX: offsetX, dstY: offsetY);
  } else {
    // Classification model: center crop to square
    resized = img.copyResizeCropSquare(image, size: p.targetWidth);
  }

  // Convert resized image to pixel buffer for deterministic pixel access
  // Use getPixel() API which is safer and version-agnostic
  final int w = resized.width;
  final int h = resized.height;
  
  if (p.isQuantized) {
    // Quantized models: use uint8 [0, 255]
    final List<dynamic> batch = List.generate(1, (_) {
      return List.generate(h, (y) {
        return List.generate(w, (x) {
          final img.Pixel pixel = resized.getPixel(x, y);
          final int r = pixel.r.toInt();
          final int g = pixel.g.toInt();
          final int b = pixel.b.toInt();
          if (p.channels == 1) return r;
          final List<int> ch = [r];
          if (p.channels > 1) ch.add(g);
          if (p.channels > 2) ch.add(b);
          return ch;
        });
      });
    });
    return _PreprocessedResult(batch);
  } else if (p.hasBuiltInRescaling) {
    // Models with built-in rescaling (MobileNetV3): feed [0, 255] values as floats
    final List<dynamic> batch = List.generate(1, (_) {
      return List.generate(h, (y) {
        return List.generate(w, (x) {
          final img.Pixel pixel = resized.getPixel(x, y);
          // Keep values in [0, 255] range as doubles (model will rescale internally)
          final double r = pixel.r.toDouble();
          final double g = pixel.g.toDouble();
          final double b = pixel.b.toDouble();
          if (p.channels == 1) return r;
          final List<double> ch = [r];
          if (p.channels > 1) ch.add(g);
          if (p.channels > 2) ch.add(b);
          return ch;
        });
      });
    });
    return _PreprocessedResult(batch);
  } else {
    // Standard float models: normalize to [0, 1] range
    final List<dynamic> batch = List.generate(1, (_) {
      return List.generate(h, (y) {
        return List.generate(w, (x) {
          final img.Pixel pixel = resized.getPixel(x, y);
          // Normalize to [0, 1] range for float models
          final double r = pixel.r / 255.0;
          final double g = pixel.g / 255.0;
          final double b = pixel.b / 255.0;
          if (p.channels == 1) return r;
          final List<double> ch = [r];
          if (p.channels > 1) ch.add(g);
          if (p.channels > 2) ch.add(b);
          return ch;
        });
      });
    });
    return _PreprocessedResult(batch);
  }
}

// helpers
List<double> _softmax(List<double> logits) {
  final maxLogit = logits.reduce((a, b) => a > b ? a : b);
  final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
  final sum = exps.fold(0.0, (a, b) => a + b);
  return exps.map((e) => e / sum).toList();
}