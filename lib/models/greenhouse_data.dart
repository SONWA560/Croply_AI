class GreenhouseData {
  final DateTime? timestamp;
  final double? temperatureBmp280;
  final double? temperatureDht22;
  final double? humidity;
  final double? pressure;
  final double? altitude;
  final int? lightRaw;
  final double? lightPercent;
  final int? flameRaw;
  final bool? flameDetected;
  final AirQualityData? airQuality;
  final FlammableGasData? flammableGas;
  final CarbonMonoxideData? carbonMonoxide;
  
  GreenhouseData({
    this.timestamp,
    this.temperatureBmp280,
    this.temperatureDht22,
    this.humidity,
    this.pressure,
    this.altitude,
    this.lightRaw,
    this.lightPercent,
    this.flameRaw,
    this.flameDetected,
    this.airQuality,
    this.flammableGas,
    this.carbonMonoxide,
  });
  
  factory GreenhouseData.fromJson(Map<String, dynamic> json) {
    return GreenhouseData(
      timestamp: json['timestamp_reading'] != null 
        ? DateTime.parse(json['timestamp_reading'])
        : null,
      temperatureBmp280: _parseDouble(json['temperature_bmp280']),
      temperatureDht22: _parseDouble(json['temperature_dht22']),
      humidity: _parseDouble(json['humidity']),
      pressure: _parseDouble(json['pressure']),
      altitude: _parseDouble(json['altitude']),
      lightRaw: json['light_raw'] as int?,
      lightPercent: _parseDouble(json['light_percent']),
      flameRaw: json['flame_raw'] as int?,
      flameDetected: _parseBool(json['flame_detected']),
      airQuality: json['mq135_raw'] != null 
        ? AirQualityData.fromJson(json) 
        : null,
      flammableGas: json['mq2_raw'] != null 
        ? FlammableGasData.fromJson(json) 
        : null,
      carbonMonoxide: json['mq7_raw'] != null 
        ? CarbonMonoxideData.fromJson(json) 
        : null,
    );
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0; // 0 = false, any other int = true
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }
  
  // Get average temperature from both sensors
  double? get averageTemperature {
    if (temperatureBmp280 != null && temperatureDht22 != null) {
      return (temperatureBmp280! + temperatureDht22!) / 2;
    }
    return temperatureBmp280 ?? temperatureDht22;
  }
  
  // Check if data is stale (older than 5 minutes)
  bool get isStale {
    if (timestamp == null) return true;
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    return difference.inMinutes > 5;
  }
}

class AirQualityData {
  final int raw;
  final int baseline;
  final int drop;
  
  AirQualityData({
    required this.raw,
    required this.baseline,
    required this.drop,
  });
  
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      raw: json['mq135_raw'] as int? ?? 0,
      baseline: json['mq135_baseline'] as int? ?? 0,
      drop: json['mq135_drop'] as int? ?? 0,
    );
  }
  
  String get qualityLevel {
    if (drop < 50) return 'Excellent';
    if (drop < 100) return 'Good';
    if (drop < 150) return 'Moderate';
    if (drop < 200) return 'Poor';
    return 'Hazardous';
  }
  
  // Color indicator for UI
  String get qualityColor {
    if (drop < 50) return '#0F4B06'; // Green
    if (drop < 100) return '#15500D'; // Light green
    if (drop < 150) return '#FFA500'; // Orange
    if (drop < 200) return '#FF6347'; // Red-orange
    return '#FF0000'; // Red
  }
}

class FlammableGasData {
  final int raw;
  final int baseline;
  final int drop;
  
  FlammableGasData({
    required this.raw,
    required this.baseline,
    required this.drop,
  });
  
  factory FlammableGasData.fromJson(Map<String, dynamic> json) {
    return FlammableGasData(
      raw: json['mq2_raw'] as int? ?? 0,
      baseline: json['mq2_baseline'] as int? ?? 0,
      drop: json['mq2_drop'] as int? ?? 0,
    );
  }
  
  bool get isDetected => drop.abs() > 10;
  
  String get level {
    if (drop.abs() < 5) return 'Normal';
    if (drop.abs() < 15) return 'Low';
    if (drop.abs() < 25) return 'Moderate';
    return 'High';
  }
}

class CarbonMonoxideData {
  final int raw;
  final int baseline;
  final int drop;
  
  CarbonMonoxideData({
    required this.raw,
    required this.baseline,
    required this.drop,
  });
  
  factory CarbonMonoxideData.fromJson(Map<String, dynamic> json) {
    return CarbonMonoxideData(
      raw: json['mq7_raw'] as int? ?? 0,
      baseline: json['mq7_baseline'] as int? ?? 0,
      drop: json['mq7_drop'] as int? ?? 0,
    );
  }
  
  String get level {
    if (drop < 50) return 'Normal';
    if (drop < 100) return 'Elevated';
    if (drop < 200) return 'High';
    return 'Dangerous';
  }
  
  bool get isDangerous => drop >= 200;
}
