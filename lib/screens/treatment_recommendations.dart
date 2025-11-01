import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import '../models/model_type.dart';
import '../services/detection_result_saver.dart';

class TreatmentRecommendationsPage extends StatefulWidget {
  static const Color primary = Color(0xFF45C91D);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF152111);
  static const Color foregroundLight = Color(0xFF131711);
  static const Color foregroundDark = Color(0xFFE8EBE7);
  static const Color subtleLight = Color(0xFF6C8764);
  static const Color subtleDark = Color(0xFFA0B59B);
  static const Color borderLight = Color(0xFFDEE5DC);
  static const Color borderDark = Color(0xFF344830);

  // Model detection fields
  final String disease;
  final String recommendation;
  final ModelType? modelType; // Optional for backward compatibility
  final File? imageFile; // Image to save
  final double? confidence; // Confidence score

  // Constructor
  const TreatmentRecommendationsPage({
    super.key,
    required this.disease,
    required this.recommendation,
    this.modelType,
    this.imageFile,
    this.confidence,
  });

  @override
  State<TreatmentRecommendationsPage> createState() => _TreatmentRecommendationsPageState();
}

class _TreatmentRecommendationsPageState extends State<TreatmentRecommendationsPage> {
  final DetectionResultSaver _saver = DetectionResultSaver();
  bool _isSaving = false;
  bool _isSaved = false;

  String _getDetectionLabel() {
    if (widget.modelType == null) return 'Detected:';
    switch (widget.modelType!) {
      case ModelType.pestDetection:
        return 'Detected Pest:';
      case ModelType.growthStage:
        return 'Detected Growth Stage:';
      case ModelType.diseaseDetection:
        return 'Detected Disease:';
    }
  }

  String _getRecommendationTitle() {
    if (widget.modelType == null) return 'Recommendations:';
    switch (widget.modelType!) {
      case ModelType.pestDetection:
        return 'Pest Control Recommendations:';
      case ModelType.growthStage:
        return 'Growth Stage Care Tips:';
      case ModelType.diseaseDetection:
        return 'Disease Treatment Recommendations:';
    }
  }

  Future<void> _saveToHistory() async {
    if (_isSaving || _isSaved || widget.imageFile == null) return;

    setState(() => _isSaving = true);

    try {
      final modelType = widget.modelType ?? ModelType.diseaseDetection;
      final confidence = (widget.confidence ?? 0.0) * 100; // Convert to percentage

      switch (modelType) {
        case ModelType.diseaseDetection:
          await _saver.saveDiseaseDetection(
            imageFile: widget.imageFile!,
            diseaseName: widget.disease,
            plantType: 'Unknown', // Can be extracted from disease name if needed
            confidence: confidence,
          );
          break;
        case ModelType.pestDetection:
          await _saver.savePestDetection(
            imageFile: widget.imageFile!,
            pestName: widget.disease,
            plantType: 'Unknown',
            confidence: confidence,
          );
          break;
        case ModelType.growthStage:
          await _saver.saveGrowthStageDetection(
            imageFile: widget.imageFile!,
            growthStage: widget.disease,
            plantType: 'Unknown',
            confidence: confidence,
          );
          break;
      }

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to My Crops successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDark ? TreatmentRecommendationsPage.backgroundDark : TreatmentRecommendationsPage.backgroundLight;
    final Color foreground = isDark ? TreatmentRecommendationsPage.foregroundDark : TreatmentRecommendationsPage.foregroundLight;
    final Color subtle = isDark ? TreatmentRecommendationsPage.subtleDark : TreatmentRecommendationsPage.subtleLight;
    final Color border = isDark ? TreatmentRecommendationsPage.borderDark : TreatmentRecommendationsPage.borderLight;

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isDark
                  ? TreatmentRecommendationsPage.backgroundDark.withOpacity(0.8)
                  : TreatmentRecommendationsPage.backgroundLight.withOpacity(0.8),
            ),
          ),
        ),
        title: Text(
          'Treatment Recommendations',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: foreground),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [SizedBox(width: 32)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              // Show dynamically based on model type
              Text(
                _getDetectionLabel(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.disease,
                style: const TextStyle(
                  color: TreatmentRecommendationsPage.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getRecommendationTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.recommendation,
                style: TextStyle(fontSize: 16, color: subtle),
              ),
              const SizedBox(height: 20),
              // Save to My Crops button
              if (widget.imageFile != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving || _isSaved ? null : _saveToHistory,
                    icon: Icon(_isSaved ? Icons.check : Icons.save),
                    label: Text(_isSaved ? 'Saved to My Crops' : _isSaving ? 'Saving...' : 'Save to My Crops'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : TreatmentRecommendationsPage.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),

              // --- Static Example Content Below ---
              Text(
                'Suggested Practices',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
              ),
              const SizedBox(height: 16),
              _TreatmentItem(
                icon: Icons.local_pharmacy,
                title: 'Fungicide Application',
                description:
                    'Apply a copper-based fungicide to affected areas (2g per liter of water).',
                primary: TreatmentRecommendationsPage.primary,
                subtle: subtle,
                foreground: foreground,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _TreatmentItem(
                icon: Icons.content_cut,
                title: 'Pruning & Sanitation',
                description:
                    'Remove infected leaves and fruit to stop the spread.',
                primary: TreatmentRecommendationsPage.primary,
                subtle: subtle,
                foreground: foreground,
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              _BottomFooter(
                primary: TreatmentRecommendationsPage.primary,
                subtle: subtle,
                border: border,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TreatmentItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color primary;
  final Color subtle;
  final Color foreground;
  final bool isDark;

  const _TreatmentItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.primary,
    required this.subtle,
    required this.foreground,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary.withOpacity(isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: foreground)),
              Text(description, style: TextStyle(fontSize: 13, color: subtle)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomFooter extends StatelessWidget {
  final Color primary;
  final Color subtle;
  final Color border;
  final bool isDark;

  const _BottomFooter({
    required this.primary,
    required this.subtle,
    required this.border,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Mark as Treated',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primary.withOpacity(isDark ? 0.3 : 0.2),
              foregroundColor: primary,
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
            ),
            child: const Text('View Crop Health',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
