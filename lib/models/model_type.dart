enum ModelType {
  pestDetection,
  growthStage,
  diseaseDetection,
}

extension ModelTypeExtension on ModelType {
  String get modelAsset {
    switch (this) {
      case ModelType.pestDetection:
        return 'assets/models/Pest_Detection_Model_saved_model/Pest_Detection_Model_int8.tflite';
      case ModelType.growthStage:
        return 'assets/models/Plant_Growth_Stage_Model_saved_model/Plant_Growth_Stage_Model_int8.tflite';
      case ModelType.diseaseDetection:
        return 'assets/models/Disease_Detection_Model.tflite';
    }
  }

  String get displayName {
    switch (this) {
      case ModelType.pestDetection:
        return 'Pest Detection';
      case ModelType.growthStage:
        return 'Plant Growth Stage';
      case ModelType.diseaseDetection:
        return 'Disease Detection';
    }
  }
}