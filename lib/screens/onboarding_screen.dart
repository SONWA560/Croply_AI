import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/onboarding_page_model.dart';
import 'user_login.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(
        pages: [
          OnboardingPageModel(
            title: 'AI-Powered Plant Detection',
            description:
                'Advanced machine learning identifies diseases, pests, and growth stages instantly with high accuracy.',
            lottieUrl: 'https://lottie.host/b0d3c5e4-9c4e-4a5f-9c5e-4a5f9c5e4a5f/xJZKZ8nJ8l.json',
            bgColor: const Color(0xFFFFFFFF),
            textColor: const Color(0xFF0F4B06),
          ),
          OnboardingPageModel(
            title: 'Real-Time Camera Analysis',
            description:
                'Point your camera at any plant for instant AI diagnosis with live bounding boxes and confidence scores.',
            lottieUrl: 'https://lottie.host/c1e4d5f6-0a5f-4b6c-8d6c-5a6f8d6c5b7e/yKALZ9oK9m.json',
            bgColor: const Color(0xFFFFFFFF),
            textColor: const Color(0xFF0F4B06),
          ),
          OnboardingPageModel(
            title: 'Expert Treatment Recommendations',
            description:
                'Get personalised treatment plans and preventive measures backed by agricultural science.',
            lottieUrl: 'https://lottie.host/d2f5e6g7-1b6g-5c7d-9e7d-6b7g9e7d6c8f/zLBMA0pL0n.json',
            bgColor: const Color(0xFFFFFFFF),
            textColor: const Color(0xFF0F4B06),
          ),
          OnboardingPageModel(
            title: 'Smart Crop Monitoring',
            description:
                'Track your crops\' health history, analyse trends, and optimise your farming with AI insights.',
            lottieUrl: 'https://lottie.host/e3g6f7h8-2c7h-6d8e-0f8e-7c8h0f8e7d9g/aMCNB1qM1o.json',
            bgColor: const Color(0xFFFFFFFF),
            textColor: const Color(0xFF0F4B06),
          ),
        ],
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UserLogin()),
            );
          }
        },
        onSkip: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UserLogin()),
            );
          }
        },
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter({
    super.key,
    required this.pages,
    this.onSkip,
    this.onFinish,
  });

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
          child: Column(
            children: [
              // Logo and Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Croply AI Logo
                    const Text(
                      'Croply AI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4B06),
                        letterSpacing: 1.2,
                      ),
                    ),
                    // Skip button
                    OutlinedButton(
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F4B06),
                        side: const BorderSide(color: Color(0xFF0F4B06), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView with Lottie animations
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentPage = idx;
                    });
                    _fadeController.reset();
                    _fadeController.forward();
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Lottie Animation
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Lottie.network(
                                item.lottieUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to placeholder icon if Lottie fails
                                  return Icon(
                                    _getIconForPage(idx),
                                    size: 150,
                                    color: const Color(0xFF0F4B06),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Title and Description
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F4B06),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Description
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF15500D),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.pages.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == idx ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == idx
                            ? const Color(0xFF0F4B06)
                            : const Color(0xFF15500D).withOpacity(0.3),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Next/Finish Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == widget.pages.length - 1) {
                        widget.onFinish?.call();
                      } else {
                        _pageController.animateToPage(
                          _currentPage + 1,
                          curve: Curves.easeInOutCubic,
                          duration: const Duration(milliseconds: 400),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4B06),
                      foregroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == widget.pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == widget.pages.length - 1
                              ? Icons.rocket_launch
                              : Icons.arrow_forward,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return MdiIcons.brain; // AI Brain
      case 1:
        return MdiIcons.camera; // Camera
      case 2:
        return MdiIcons.hospital; // Treatment
      case 3:
        return MdiIcons.chartBox; // Analytics
      default:
        return MdiIcons.seedOutline; // Agriculture
    }
  }
}
