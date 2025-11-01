import 'dart:io';
import 'package:path/path.dart' as path;
import 'crop_history_service.dart';

class DetectionResultSaver {
  final CropHistoryService _cropHistoryService = CropHistoryService();

  /// Save disease detection result
  Future<String> saveDiseaseDetection({
    required File imageFile,
    required String diseaseName,
    required String plantType,
    required double confidence,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Generate unique filename
      final String fileName = 'disease_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Upload image to Firebase Storage
      final uploadResult = await _cropHistoryService.uploadImage(imageFile, fileName);
      
      // Save to Firestore
      final analysisId = await _cropHistoryService.saveCropAnalysis(
        imageUrl: uploadResult['url']!,
        imagePath: uploadResult['path']!,
        title: 'Disease: $diseaseName',
        subtitle: plantType,
        cropType: plantType,
        healthStatus: 'Diseased',
        analysisType: 'disease',
        confidence: confidence,
        date: DateTime.now(),
        detectionDetails: {
          'diseaseName': diseaseName,
          'modelUsed': 'Disease_Detection_Model',
          ...?additionalData,
        },
        metadata: {
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return analysisId;
    } catch (e) {
      throw Exception('Failed to save disease detection: $e');
    }
  }

  /// Save pest detection result
  Future<String> savePestDetection({
    required File imageFile,
    required String pestName,
    required String plantType,
    required double confidence,
    List<Map<String, dynamic>>? detections,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final String fileName = 'pest_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final uploadResult = await _cropHistoryService.uploadImage(imageFile, fileName);
      
      final analysisId = await _cropHistoryService.saveCropAnalysis(
        imageUrl: uploadResult['url']!,
        imagePath: uploadResult['path']!,
        title: 'Pest: $pestName',
        subtitle: plantType,
        cropType: plantType,
        healthStatus: 'Pest-infested',
        analysisType: 'pest',
        confidence: confidence,
        date: DateTime.now(),
        detectionDetails: {
          'pestName': pestName,
          'modelUsed': 'Pest_Detection_Model',
          if (detections != null) 'boundingBoxes': detections,
          ...?additionalData,
        },
        metadata: {
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return analysisId;
    } catch (e) {
      throw Exception('Failed to save pest detection: $e');
    }
  }

  /// Save growth stage detection result
  Future<String> saveGrowthStageDetection({
    required File imageFile,
    required String growthStage,
    required String plantType,
    required double confidence,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final String fileName = 'growth_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final uploadResult = await _cropHistoryService.uploadImage(imageFile, fileName);
      
      final analysisId = await _cropHistoryService.saveCropAnalysis(
        imageUrl: uploadResult['url']!,
        imagePath: uploadResult['path']!,
        title: 'Growth Stage: $growthStage',
        subtitle: plantType,
        cropType: plantType,
        healthStatus: 'Healthy',
        analysisType: 'growth_stage',
        confidence: confidence,
        date: DateTime.now(),
        detectionDetails: {
          'growthStage': growthStage,
          'modelUsed': 'Plant_Growth_Stage_Model',
          ...?additionalData,
        },
        metadata: {
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return analysisId;
    } catch (e) {
      throw Exception('Failed to save growth stage detection: $e');
    }
  }

  /// Save healthy crop result
  Future<String> saveHealthyCrop({
    required File imageFile,
    required String plantType,
    required double confidence,
    String? additionalInfo,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final String fileName = 'healthy_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final uploadResult = await _cropHistoryService.uploadImage(imageFile, fileName);
      
      final analysisId = await _cropHistoryService.saveCropAnalysis(
        imageUrl: uploadResult['url']!,
        imagePath: uploadResult['path']!,
        title: 'Healthy Crop',
        subtitle: additionalInfo ?? plantType,
        cropType: plantType,
        healthStatus: 'Healthy',
        analysisType: 'healthy',
        confidence: confidence,
        date: DateTime.now(),
        detectionDetails: {
          'plantType': plantType,
          if (additionalInfo != null) 'notes': additionalInfo,
          ...?additionalData,
        },
        metadata: {
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return analysisId;
    } catch (e) {
      throw Exception('Failed to save healthy crop: $e');
    }
  }

  /// Generic save method for custom analysis types
  Future<String> saveCustomAnalysis({
    required File imageFile,
    required String title,
    required String subtitle,
    required String cropType,
    required String healthStatus,
    required String analysisType,
    required double confidence,
    Map<String, dynamic>? detectionDetails,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final String fileName = '${analysisType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final uploadResult = await _cropHistoryService.uploadImage(imageFile, fileName);
      
      final analysisId = await _cropHistoryService.saveCropAnalysis(
        imageUrl: uploadResult['url']!,
        imagePath: uploadResult['path']!,
        title: title,
        subtitle: subtitle,
        cropType: cropType,
        healthStatus: healthStatus,
        analysisType: analysisType,
        confidence: confidence,
        date: DateTime.now(),
        detectionDetails: detectionDetails,
        metadata: {
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      return analysisId;
    } catch (e) {
      throw Exception('Failed to save custom analysis: $e');
    }
  }
}
