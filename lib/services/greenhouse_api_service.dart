import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/greenhouse_data.dart';

class GreenhouseApiService {
  static const String baseUrl = 'https://oracleapex.com/ords/g3_data/iot/greenhouse/';
  
  // Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 10);
  
  /// Fetch latest sensor data (most recent reading)
  Future<GreenhouseData?> fetchLatestData() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(timeout);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle different response formats based on actual API structure
        if (jsonData is Map && jsonData.containsKey('items')) {
          final readings = jsonData['items'] as List;
          if (readings.isNotEmpty) {
            return GreenhouseData.fromJson(readings.first);
          }
        } else if (jsonData is List && jsonData.isNotEmpty) {
          return GreenhouseData.fromJson(jsonData.first);
        } else if (jsonData is Map) {
          return GreenhouseData.fromJson(Map<String, dynamic>.from(jsonData));
        }
      } else {
        print('API Error: Status ${response.statusCode}');
      }
      return null;
    } on http.ClientException catch (e) {
      print('Network error fetching greenhouse data: $e');
      return null;
    } catch (e) {
      print('Error fetching greenhouse data: $e');
      return null;
    }
  }
  
  /// Fetch multiple readings (up to specified limit)
  Future<List<GreenhouseData>> fetchAllData({int limit = 20}) async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(timeout);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> readings = [];
        
        if (jsonData is Map && jsonData.containsKey('items')) {
          readings = jsonData['items'];
        } else if (jsonData is List) {
          readings = jsonData;
        }
        
        // Limit the number of readings
        if (readings.length > limit) {
          readings = readings.sublist(0, limit);
        }
        
        return readings
            .map((json) => GreenhouseData.fromJson(json))
            .toList();
      } else {
        print('API Error: Status ${response.statusCode}');
      }
      return [];
    } on http.ClientException catch (e) {
      print('Network error fetching all greenhouse data: $e');
      return [];
    } catch (e) {
      print('Error fetching all greenhouse data: $e');
      return [];
    }
  }
  
  /// Get historical data for charts (last N readings)
  Future<List<GreenhouseData>> fetchHistoricalData({int count = 10}) async {
    try {
      final allData = await fetchAllData(limit: count);
      // Sort by timestamp (newest first)
      allData.sort((a, b) {
        if (a.timestamp == null || b.timestamp == null) return 0;
        return b.timestamp!.compareTo(a.timestamp!);
      });
      return allData;
    } catch (e) {
      print('Error fetching historical data: $e');
      return [];
    }
  }
  
  /// Check if API is accessible
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }
  
  /// Get average temperature over last N readings
  Future<double?> getAverageTemperature({int readings = 5}) async {
    try {
      final data = await fetchAllData(limit: readings);
      if (data.isEmpty) return null;
      
      final temps = data
          .map((d) => d.averageTemperature)
          .where((t) => t != null)
          .toList();
      
      if (temps.isEmpty) return null;
      
      final sum = temps.reduce((a, b) => a! + b!)!;
      return sum / temps.length;
    } catch (e) {
      print('Error calculating average temperature: $e');
      return null;
    }
  }
  
  /// Get temperature trend (increasing, decreasing, stable)
  Future<String> getTemperatureTrend({int readings = 5}) async {
    try {
      final data = await fetchHistoricalData(count: readings);
      if (data.length < 2) return 'Unknown';
      
      final temps = data
          .map((d) => d.averageTemperature)
          .where((t) => t != null)
          .toList();
      
      if (temps.length < 2) return 'Unknown';
      
      final first = temps.first!;
      final last = temps.last!;
      final diff = first - last;
      
      if (diff > 0.5) return 'Increasing';
      if (diff < -0.5) return 'Decreasing';
      return 'Stable';
    } catch (e) {
      print('Error calculating temperature trend: $e');
      return 'Unknown';
    }
  }
}
