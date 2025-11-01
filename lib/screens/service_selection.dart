import 'package:flutter/material.dart';
import 'upload_screen.dart'; // Import the upload screen widget

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String _selectedService = 'Growth Classification';
  int _currentNavIndex = 0;

  final List<String> _services = [
    'Growth Classification',
    'Disease Detection',
    'Pest Detection',
  ];

  final List<Map<String, dynamic>> _serviceCards = [
    {
      'icon': Icons.local_florist,
      'label': 'Growth',
      'value': 'Growth Classification',
    },
    {
      'icon': Icons.sick,
      'label': 'Disease',
      'value': 'Disease Detection',
    },
    {
      'icon': Icons.pest_control,
      'label': 'Pest',
      'value': 'Pest Detection',
    },
  ];

  void _onServiceChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedService = newValue;
      });
    }
  }

  void _onServiceCardTap(String service) {
    setState(() {
      _selectedService = service;
    });
  }

  void _onProceed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proceeding with $_selectedService'),
        backgroundColor: const Color(0xFF45c91d),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageUploadPage(serviceType: _selectedService),
      ),
    );
  }

  void _onBack() {
    Navigator.pop(context);
  }

  void _onNavTap(int index) {
    if (_currentNavIndex == index) return;

    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/my_crops');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF152111) : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: _buildHeader(isDark),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildTitleSection(isDark),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildServiceDropdown(isDark),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildServiceCardsGrid(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: _buildProceedButton(isDark),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onBack,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? const Color(0xFFF6F8F6) : const Color(0xFF152111),
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Croply AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF6F8F6) : const Color(0xFF152111),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Service',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF6F8F6) : const Color(0xFF152111),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a service to get started with your crop analysis.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF152111) : const Color(0xFFF6F8F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2A3C28) : const Color(0xFFDEE5DC),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedService,
              isExpanded: true,
              icon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFF6F8F6) : const Color(0xFF152111),
                fontFamily: 'Inter',
              ),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              dropdownColor: isDark ? const Color(0xFF1E2F1B) : Colors.white,
              items: _services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: _onServiceChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCardsGrid(bool isDark) {
    return Row(
      children: _serviceCards.map((card) {
        final isSelected = _selectedService == card['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onServiceCardTap(card['value']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF45c91d).withOpacity(0.1)
                      : (isDark ? const Color(0xFF152111) : const Color(0xFFF6F8F6)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      card['icon'],
                      size: 32,
                      color: isSelected
                          ? const Color(0xFF45c91d)
                          : (isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? (isDark ? const Color(0xFFF6F8F6) : const Color(0xFF152111))
                            : (isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764)),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProceedButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: const Color(0xFF45c91d).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ]),
        child: ElevatedButton(
          onPressed: _onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF45c91d),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Proceed',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152111) : const Color(0xFFF6F8F6),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A3C28) : const Color(0xFFDEE5DC),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: _currentNavIndex == 0,
                onTap: () => _onNavTap(0),
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.grass,
                label: 'My Crops',
                isActive: _currentNavIndex == 1,
                onTap: () => _onNavTap(1),
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                isActive: _currentNavIndex == 2,
                onTap: () => _onNavTap(2),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final color = isActive
        ? const Color(0xFF45c91d)
        : (isDark ? const Color(0xFFA3B3A0) : const Color(0xFF6C8764));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
