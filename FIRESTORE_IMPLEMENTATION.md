# Firestore Integration - Phase 1 & 2 Complete

## Overview
Successfully implemented Firestore database schema and core service layer for storing and managing crop analysis history.

---

## 🔒 Phase 1: Firestore Security Rules

**File:** `firestore.rules`

### Features Implemented:
- ✅ User-specific data isolation (users can only access their own data)
- ✅ Authentication requirement for all operations
- ✅ Field validation on document creation
- ✅ Confidence score validation (0-100 range)
- ✅ Analysis type validation (disease, pest, growth_stage, healthy)
- ✅ Protection against tampering with core fields (createdAt, imageUrl, imagePath)

### Security Model:
```
/users/{userId}/crop_history/{analysisId}
- READ: Authenticated user who owns the data
- CREATE: Authenticated user with valid data structure
- UPDATE: Authenticated user (restricted fields)
- DELETE: Authenticated user who owns the data
```

---

## 🛠️ Phase 2: Service Layer

### 2.1 CropHistoryService
**File:** `lib/services/crop_history_service.dart`

Core service for all Firestore and Firebase Storage operations.

#### Key Methods:

**Upload & Storage:**
```dart
Future<Map<String, String>> uploadImage(File imageFile, String fileName)
// Returns: { 'url': downloadUrl, 'path': storagePath }
```

**Create Operations:**
```dart
Future<String> saveCropAnalysis({
  required String imageUrl,
  required String imagePath,
  required String title,
  required String subtitle,
  required String cropType,
  required String healthStatus,
  required String analysisType,
  required double confidence,
  required DateTime date,
  Map<String, dynamic>? detectionDetails,
  Map<String, dynamic>? metadata,
})
// Returns: documentId
```

**Read Operations:**
```dart
// Real-time stream of all crop history
Stream<List<Map<String, dynamic>>> getCropHistory()

// Filtered stream with crop type, health status, and sorting
Stream<List<Map<String, dynamic>>> getFilteredCropHistory({
  String? cropType,
  String? healthStatus,
  String? sortOrder,
})

// Get single crop by ID
Future<Map<String, dynamic>?> getCropById(String documentId)

// Search crops by text
Future<List<Map<String, dynamic>>> searchCrops(String searchText)
```

**Update Operations:**
```dart
Future<void> updateCropRecord(String documentId, Map<String, dynamic> updates)
```

**Delete Operations:**
```dart
// Delete crop record and associated image
Future<void> deleteCropRecord(String documentId)

// Delete image from storage
Future<void> deleteImageFromStorage(String imagePath)

// Batch delete multiple crops
Future<void> deleteMultipleCrops(List<String> documentIds)
```

**Statistics:**
```dart
// Get breakdown by health status
Future<Map<String, int>> getCropStatistics()

// Get total count
Future<int> getTotalAnalysisCount()
```

---

### 2.2 DetectionResultSaver
**File:** `lib/services/detection_result_saver.dart`

Helper service that wraps CropHistoryService for specific detection types.

#### Methods:

**Disease Detection:**
```dart
Future<String> saveDiseaseDetection({
  required File imageFile,
  required String diseaseName,
  required String plantType,
  required double confidence,
  Map<String, dynamic>? additionalData,
})
```

**Pest Detection:**
```dart
Future<String> savePestDetection({
  required File imageFile,
  required String pestName,
  required String plantType,
  required double confidence,
  List<Map<String, dynamic>>? detections, // YOLO bounding boxes
  Map<String, dynamic>? additionalData,
})
```

**Growth Stage Detection:**
```dart
Future<String> saveGrowthStageDetection({
  required File imageFile,
  required String growthStage,
  required String plantType,
  required double confidence,
  Map<String, dynamic>? additionalData,
})
```

**Healthy Crop:**
```dart
Future<String> saveHealthyCrop({
  required File imageFile,
  required String plantType,
  required double confidence,
  String? additionalInfo,
  Map<String, dynamic>? additionalData,
})
```

**Custom Analysis:**
```dart
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
})
```

---

## 📊 Database Schema

### Collection Structure:
```
users/{userId}/crop_history/{analysisId}
```

### Document Fields:
```dart
{
  'imageUrl': String,           // Firebase Storage download URL
  'imagePath': String,          // Storage path for deletion
  'title': String,              // e.g., "Disease: Early Blight"
  'subtitle': String,           // e.g., "Tomato Plant"
  'cropType': String,           // e.g., "Tomato", "Apple", "Plum"
  'healthStatus': String,       // "Healthy", "Diseased", "Pest-infested"
  'analysisType': String,       // "disease", "pest", "growth_stage", "healthy"
  'confidence': Number,         // 0-100
  'date': Timestamp,            // Analysis date
  'createdAt': Timestamp,       // Server timestamp
  'userId': String,             // Owner's user ID
  'detectionDetails': {         // Optional
    'modelUsed': String,
    'detectedClass': String,
    'processingTime': Number,
    // ... model-specific data
  },
  'metadata': {                 // Optional
    'appVersion': String,
    'timestamp': String,
    // ... additional metadata
  }
}
```

---

## 🎯 Usage Examples

### Example 1: Save Disease Detection Result
```dart
import 'dart:io';
import 'package:croply_ai/services/detection_result_saver.dart';

final saver = DetectionResultSaver();

try {
  final analysisId = await saver.saveDiseaseDetection(
    imageFile: File('/path/to/image.jpg'),
    diseaseName: 'Early Blight',
    plantType: 'Tomato',
    confidence: 87.5,
    additionalData: {
      'processingTime': 1250, // ms
      'modelVersion': '1.0.0',
    },
  );
  
  print('Saved with ID: $analysisId');
} catch (e) {
  print('Error: $e');
}
```

### Example 2: Display Crop History with Filters
```dart
import 'package:croply_ai/services/crop_history_service.dart';

final service = CropHistoryService();

// In your widget:
StreamBuilder<List<Map<String, dynamic>>>(
  stream: service.getFilteredCropHistory(
    cropType: 'Tomato',
    healthStatus: 'Diseased',
    sortOrder: 'Newest First',
  ),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final crops = snapshot.data!;
      return ListView.builder(
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return ListTile(
            title: Text(crop['title']),
            subtitle: Text(crop['subtitle']),
            trailing: Text('${crop['confidence'].toStringAsFixed(1)}%'),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### Example 3: Delete Crop Record
```dart
final service = CropHistoryService();

await service.deleteCropRecord('analysisId123');
// This deletes both the Firestore document AND the Storage image
```

### Example 4: Get Statistics
```dart
final service = CropHistoryService();

final stats = await service.getCropStatistics();
print('Total: ${stats['total']}');
print('Healthy: ${stats['healthy']}');
print('Diseased: ${stats['diseased']}');
print('Pest-infested: ${stats['pestInfested']}');
```

---

## 🚀 Next Steps (Phase 3)

To integrate into the app:

1. **Update crops_dashboard.dart:**
   - Replace mock data with `getFilteredCropHistory()` stream
   - Add loading/error states
   - Implement swipe-to-delete

2. **Integrate into detection screens:**
   - Call `DetectionResultSaver` methods after ML inference
   - Show saving progress indicator
   - Display success/error messages

3. **Add offline support:**
   - Enable Firestore persistence
   - Handle offline/online state transitions

4. **Deploy Security Rules:**
   - Upload `firestore.rules` to Firebase Console
   - Test with Firebase Emulator Suite

---

## ✅ Testing Checklist

- [ ] Test image upload to Firebase Storage
- [ ] Test saving crop analysis to Firestore
- [ ] Test filtering by crop type
- [ ] Test filtering by health status
- [ ] Test sorting (newest/oldest)
- [ ] Test search functionality
- [ ] Test delete operation (document + image)
- [ ] Test batch delete
- [ ] Test statistics calculation
- [ ] Verify security rules in Firebase Console
- [ ] Test with unauthenticated user (should fail)
- [ ] Test with different users (data isolation)

---

## 📝 Notes

- All services handle authentication automatically via `FirebaseAuth.currentUser`
- Images are stored in user-specific folders: `crop_images/{userId}/`
- Delete operations remove both Firestore document and Storage image
- All operations include proper error handling with descriptive messages
- Services use streams for real-time updates
- Confidence scores are stored as 0-100 (not 0-1)

---

## 🔐 Security Considerations

1. **Authentication Required:** All operations require authenticated user
2. **Data Isolation:** Users can only access their own data
3. **Field Validation:** Firestore rules validate required fields and data types
4. **Image Cleanup:** Deleted records also remove associated images
5. **Protected Fields:** Core fields (createdAt, imageUrl, imagePath) cannot be modified after creation

---

**Status:** ✅ Phase 1 & 2 Complete - Ready for Phase 3 (UI Integration)
