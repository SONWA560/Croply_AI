import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CropHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference for user's crop history
  CollectionReference get _userCropsCollection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId).collection('crop_history');
  }

  /// Upload image to Firebase Storage and return download URL
  Future<Map<String, String>> uploadImage(File imageFile, String fileName) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique path for the image
      final String path = 'crop_images/$_userId/$fileName';
      final Reference storageRef = _storage.ref().child(path);

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return {
        'url': downloadUrl,
        'path': path,
      };
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Save crop analysis result to Firestore
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
  }) async {
    try {
      final docRef = await _userCropsCollection.add({
        'imageUrl': imageUrl,
        'imagePath': imagePath,
        'title': title,
        'subtitle': subtitle,
        'cropType': cropType,
        'healthStatus': healthStatus,
        'analysisType': analysisType,
        'confidence': confidence,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': _userId,
        if (detectionDetails != null) 'detectionDetails': detectionDetails,
        if (metadata != null) 'metadata': metadata,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save crop analysis: $e');
    }
  }

  /// Get all crop history for current user
  Stream<List<Map<String, dynamic>>> getCropHistory() {
    try {
      return _userCropsCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'imageUrl': data['imageUrl'] ?? '',
            'imagePath': data['imagePath'] ?? '',
            'title': data['title'] ?? 'Unknown',
            'subtitle': data['subtitle'] ?? '',
            'cropType': data['cropType'] ?? 'Unknown',
            'healthStatus': data['healthStatus'] ?? 'Unknown',
            'analysisType': data['analysisType'] ?? 'unknown',
            'confidence': data['confidence'] ?? 0.0,
            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
            if (data['detectionDetails'] != null) 
              'detectionDetails': data['detectionDetails'],
            if (data['metadata'] != null) 
              'metadata': data['metadata'],
          };
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get crop history: $e');
    }
  }

  /// Get filtered crop history
  Stream<List<Map<String, dynamic>>> getFilteredCropHistory({
    String? cropType,
    String? healthStatus,
    String? sortOrder, // 'Newest First', 'Oldest First', or 'Date'
  }) {
    try {
      Query query = _userCropsCollection;

      // Apply filters
      if (cropType != null && cropType != 'Crop Type') {
        query = query.where('cropType', isEqualTo: cropType);
      }

      if (healthStatus != null && healthStatus != 'Health Status') {
        query = query.where('healthStatus', isEqualTo: healthStatus);
      }

      // Apply sorting
      final bool descending = sortOrder != 'Oldest First';
      query = query.orderBy('date', descending: descending);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'imageUrl': data['imageUrl'] ?? '',
            'imagePath': data['imagePath'] ?? '',
            'title': data['title'] ?? 'Unknown',
            'subtitle': data['subtitle'] ?? '',
            'cropType': data['cropType'] ?? 'Unknown',
            'healthStatus': data['healthStatus'] ?? 'Unknown',
            'analysisType': data['analysisType'] ?? 'unknown',
            'confidence': data['confidence'] ?? 0.0,
            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
            if (data['detectionDetails'] != null) 
              'detectionDetails': data['detectionDetails'],
            if (data['metadata'] != null) 
              'metadata': data['metadata'],
          };
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get filtered crop history: $e');
    }
  }

  /// Get a single crop record by ID
  Future<Map<String, dynamic>?> getCropById(String documentId) async {
    try {
      final doc = await _userCropsCollection.doc(documentId).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'imageUrl': data['imageUrl'] ?? '',
        'imagePath': data['imagePath'] ?? '',
        'title': data['title'] ?? 'Unknown',
        'subtitle': data['subtitle'] ?? '',
        'cropType': data['cropType'] ?? 'Unknown',
        'healthStatus': data['healthStatus'] ?? 'Unknown',
        'analysisType': data['analysisType'] ?? 'unknown',
        'confidence': data['confidence'] ?? 0.0,
        'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
        if (data['detectionDetails'] != null) 
          'detectionDetails': data['detectionDetails'],
        if (data['metadata'] != null) 
          'metadata': data['metadata'],
      };
    } catch (e) {
      throw Exception('Failed to get crop by ID: $e');
    }
  }

  /// Delete a crop record and its associated image
  Future<void> deleteCropRecord(String documentId) async {
    try {
      // Get the document first to retrieve image path
      final doc = await _userCropsCollection.doc(documentId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imagePath = data['imagePath'] as String?;
        
        // Delete the document
        await _userCropsCollection.doc(documentId).delete();
        
        // Delete the image from storage if path exists
        if (imagePath != null && imagePath.isNotEmpty) {
          try {
            await _storage.ref().child(imagePath).delete();
          } catch (e) {
            // Log but don't throw - document is already deleted
            print('Failed to delete image from storage: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to delete crop record: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImageFromStorage(String imagePath) async {
    try {
      await _storage.ref().child(imagePath).delete();
    } catch (e) {
      throw Exception('Failed to delete image from storage: $e');
    }
  }

  /// Update a crop record
  Future<void> updateCropRecord(String documentId, Map<String, dynamic> updates) async {
    try {
      await _userCropsCollection.doc(documentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update crop record: $e');
    }
  }

  /// Search crops by text (searches in title, subtitle, and cropType)
  Future<List<Map<String, dynamic>>> searchCrops(String searchText) async {
    try {
      final snapshot = await _userCropsCollection.get();
      
      final results = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().toLowerCase();
        final subtitle = (data['subtitle'] ?? '').toString().toLowerCase();
        final cropType = (data['cropType'] ?? '').toString().toLowerCase();
        final searchLower = searchText.toLowerCase();
        
        return title.contains(searchLower) ||
               subtitle.contains(searchLower) ||
               cropType.contains(searchLower);
      }).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'imageUrl': data['imageUrl'] ?? '',
          'imagePath': data['imagePath'] ?? '',
          'title': data['title'] ?? 'Unknown',
          'subtitle': data['subtitle'] ?? '',
          'cropType': data['cropType'] ?? 'Unknown',
          'healthStatus': data['healthStatus'] ?? 'Unknown',
          'analysisType': data['analysisType'] ?? 'unknown',
          'confidence': data['confidence'] ?? 0.0,
          'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          if (data['detectionDetails'] != null) 
            'detectionDetails': data['detectionDetails'],
          if (data['metadata'] != null) 
            'metadata': data['metadata'],
        };
      }).toList();

      return results;
    } catch (e) {
      throw Exception('Failed to search crops: $e');
    }
  }

  /// Get crop statistics for the current user
  Future<Map<String, int>> getCropStatistics() async {
    try {
      final snapshot = await _userCropsCollection.get();
      
      int totalAnalyses = snapshot.docs.length;
      int healthyCount = 0;
      int diseasedCount = 0;
      int pestInfestedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final healthStatus = data['healthStatus'] as String?;
        
        if (healthStatus == 'Healthy') {
          healthyCount++;
        } else if (healthStatus == 'Diseased') {
          diseasedCount++;
        } else if (healthStatus == 'Pest-infested') {
          pestInfestedCount++;
        }
      }

      return {
        'total': totalAnalyses,
        'healthy': healthyCount,
        'diseased': diseasedCount,
        'pestInfested': pestInfestedCount,
      };
    } catch (e) {
      throw Exception('Failed to get crop statistics: $e');
    }
  }

  /// Get total analysis count
  Future<int> getTotalAnalysisCount() async {
    try {
      final snapshot = await _userCropsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get total analysis count: $e');
    }
  }

  /// Delete multiple crops at once (batch operation)
  Future<void> deleteMultipleCrops(List<String> documentIds) async {
    try {
      final WriteBatch batch = _firestore.batch();
      
      for (final id in documentIds) {
        final docRef = _userCropsCollection.doc(id);
        batch.delete(docRef);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple crops: $e');
    }
  }
}
