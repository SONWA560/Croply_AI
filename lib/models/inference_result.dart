import 'model_type.dart';

class InferenceResult {
  final String label;
  final double confidence;
  final int inferenceTimeMs;
  final ModelType modelType;

  InferenceResult({
    required this.label,
    required this.confidence,
    required this.inferenceTimeMs,
    required this.modelType,
  });
}