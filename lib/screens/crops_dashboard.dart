import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:croply_ai/services/crop_history_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCropsPage extends StatefulWidget {
  const MyCropsPage({super.key});

  @override
  State<MyCropsPage> createState() => _MyCropsPageState();
}

class _MyCropsPageState extends State<MyCropsPage> {
  final CropHistoryService _cropService = CropHistoryService();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Filter states
  String _cropType = 'Crop Type';
  String _healthStatus = 'Health Status';
  String _dateSort = 'Date';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Check authentication status
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (_auth.currentUser == null) {
      // User not authenticated, navigate to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to view your crops'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Invalid date';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  static const Color primary = Color(0xFF45C91D);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF152111);
  static const Color textLight = Color(0xFF18181B);
  static const Color textDark = Color(0xFFF4F4F5);
  static const Color mutedLight = Color(0xFF71717A);
  static const Color mutedDark = Color(0xFFA1A1AA);
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color borderDark = Color(0xFF27272A);
  static const Color searchIcon = Color(0xFFA1A1AA);
  static const Color dateText = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDark ? backgroundDark : backgroundLight;
    final Color textColor = isDark ? textDark : textLight;
    final Color mutedColor = isDark ? mutedDark : mutedLight;
    final Color borderColor = isDark ? borderDark : borderLight;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: isDark ? backgroundDark : backgroundLight,
        elevation: 0,
        title: Text(
          'My Crops',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: textColor
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            // Check if we can pop, otherwise navigate to dashboard
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          },
        ),
        shape: Border(bottom: BorderSide(color: isDark ? borderDark : borderLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by crop, disease, date...',
                hintStyle: const TextStyle(color: searchIcon),
                prefixIcon: const Icon(Icons.search, color: searchIcon),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: searchIcon),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primary),
                ),
                fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _cropType,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primary),
                      ),
                      fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      isDense: true,
                    ),
                    style: TextStyle(color: mutedColor, fontSize: 11),
                    items: ['Crop Type', 'Plums', 'Apricots', 'Apples', 'Tomato']
                        .map((String value) =>
                            DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))))
                        .toList(),
                    onChanged: (value) => setState(() => _cropType = value!),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _healthStatus,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primary),
                      ),
                      fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      isDense: true,
                    ),
                    style: TextStyle(color: mutedColor, fontSize: 11),
                    items: ['Health Status', 'Healthy', 'Diseased', 'Pest-infested']
                        .map((String value) =>
                            DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))))
                        .toList(),
                    onChanged: (value) => setState(() => _healthStatus = value!),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _dateSort,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primary),
                      ),
                      fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      isDense: true,
                    ),
                    style: TextStyle(color: mutedColor, fontSize: 11),
                    items: ['Date', 'Newest First', 'Oldest First']
                        .map((String value) =>
                            DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))))
                        .toList(),
                    onChanged: (value) => setState(() => _dateSort = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _cropService.getFilteredCropHistory(
                  cropType: _cropType == 'Crop Type' ? null : _cropType,
                  healthStatus: _healthStatus == 'Health Status' ? null : _healthStatus,
                  sortOrder: _dateSort == 'Date' ? null : _dateSort,
                ),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primary,
                      ),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    final errorMessage = snapshot.error.toString();
                    final isAuthError = errorMessage.contains('not authenticated');
                    
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAuthError ? Icons.lock_outline : Icons.error_outline,
                            size: 64,
                            color: mutedColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAuthError ? 'Authentication Required' : 'Error loading crops',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              isAuthError
                                  ? 'Please log in to view your crop history'
                                  : errorMessage,
                              style: TextStyle(color: mutedColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (isAuthError) {
                                Navigator.pushReplacementNamed(context, '/login');
                              } else {
                                setState(() {}); // Trigger rebuild to retry
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isAuthError ? 'Go to Login' : 'Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Get crops and apply search filter
                  List<Map<String, dynamic>> crops = snapshot.data ?? [];
                  
                  if (_searchQuery.isNotEmpty) {
                    crops = crops.where((crop) {
                      final title = crop['title']?.toString().toLowerCase() ?? '';
                      final subtitle = crop['subtitle']?.toString().toLowerCase() ?? '';
                      final cropType = crop['cropType']?.toString().toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return title.contains(query) || 
                             subtitle.contains(query) || 
                             cropType.contains(query);
                    }).toList();
                  }

                  // Empty state
                  if (crops.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 80,
                            color: mutedColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty 
                                ? 'No crops found'
                                : 'No crops yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try adjusting your search or filters'
                                : 'Start analyzing crops to see them here',
                            style: TextStyle(
                              fontSize: 14,
                              color: mutedColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/services');
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Start Analyzing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // List with data
                  return ListView.builder(
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return Dismissible(
                        key: Key(crop['id'] ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Crop'),
                              content: const Text(
                                'Are you sure you want to delete this crop record? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await _cropService.deleteCropRecord(crop['id']);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Crop deleted successfully'),
                                  backgroundColor: primary,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting crop: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: _CropItem(
                          imageUrl: crop['imageUrl'] ?? '',
                          title: crop['title'] ?? 'Unknown',
                          subtitle: crop['subtitle'] ?? '',
                          date: _formatDate(crop['date']),
                          confidence: crop['confidence']?.toDouble() ?? 0.0,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          dateColor: dateText,
                          isDark: isDark,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String date;
  final double confidence;
  final Color textColor;
  final Color mutedColor;
  final Color dateColor;
  final bool isDark;

  const _CropItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.confidence,
    required this.textColor,
    required this.mutedColor,
    required this.dateColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to details if needed
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                      width: 64, height: 64, child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: mutedColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 12, color: Color(0xFF45C91D)),
                      const SizedBox(width: 4),
                      Text(
                        '${confidence.toStringAsFixed(1)}% confidence',
                        style: TextStyle(fontSize: 10, color: mutedColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: TextStyle(fontSize: 10, color: dateColor)),
                const SizedBox(height: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: mutedColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
