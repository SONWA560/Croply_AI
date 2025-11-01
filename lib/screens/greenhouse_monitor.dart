import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/greenhouse_api_service.dart';
import '../models/greenhouse_data.dart';

class GreenhouseMonitor extends StatefulWidget {
  const GreenhouseMonitor({super.key});

  @override
  State<GreenhouseMonitor> createState() => _GreenhouseMonitorState();
}

class _GreenhouseMonitorState extends State<GreenhouseMonitor> {
  static const Color primary = Color(0xFF0F4B06);
  static const Color secondary = Color(0xFF15500D);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFEFEFE);
  
  final GreenhouseApiService _apiService = GreenhouseApiService();
  GreenhouseData? _currentData;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }
  
  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadData(showLoading: false);
        _startAutoRefresh();
      }
    });
  }
  
  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final data = await _apiService.fetchLatestData();
      if (mounted) {
        setState(() {
          _currentData = data;
          _isLoading = false;
          _errorMessage = data == null ? 'No data available' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Greenhouse Monitor'),
        backgroundColor: primary,
        foregroundColor: const Color(0xFFFFFFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildDataView(),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: primary),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: primary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentData?.timestamp != null) _buildTimestamp(),
            const SizedBox(height: 16),
            _buildTemperatureCard(),
            const SizedBox(height: 16),
            _buildEnvironmentalCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimestamp() {
    final formatter = DateFormat('MMM dd, HH:mm:ss');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: primary),
          const SizedBox(width: 8),
          Text(
            'Updated: ${formatter.format(_currentData!.timestamp!)}',
            style: const TextStyle(color: secondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemperatureCard() {
    return Card(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.thermostat, color: primary, size: 24),
                SizedBox(width: 12),
                Text('Temperature', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReading('BMP280', _currentData?.temperatureBmp280, '°C'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReading('DHT22', _currentData?.temperatureDht22, '°C'),
                ),
              ],
            ),
            if (_currentData?.averageTemperature != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Average: ${_currentData!.averageTemperature!.toStringAsFixed(1)}°C',
                  style: const TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnvironmentalCard() {
    return Card(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: primary, size: 24),
                SizedBox(width: 12),
                Text('Environment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildReading('Humidity', _currentData?.humidity, '%'),
            const SizedBox(height: 12),
            _buildReading('Pressure', _currentData?.pressure, 'hPa'),
            const SizedBox(height: 12),
            _buildReading('Light', _currentData?.lightRaw?.toDouble(), 'raw'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReading(String label, double? value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: secondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value != null ? '${value.toStringAsFixed(1)} $unit' : 'N/A',
            style: const TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
