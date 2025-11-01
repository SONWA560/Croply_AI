import 'package:croply_ai/screens/settings.dart';
import 'package:croply_ai/screens/user_login.dart';
import 'package:croply_ai/screens/user_registration.dart';
import 'package:croply_ai/screens/ai_analysis_dashboard.dart';
import 'package:croply_ai/screens/crops_dashboard.dart';
import 'package:croply_ai/screens/upload_screen.dart';
import 'package:croply_ai/screens/service_selection.dart';
import 'package:croply_ai/screens/treatment_recommendations.dart';
import 'package:croply_ai/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app_state.dart'; // import app_state

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  
  // TEMPORARY: Uncomment the line below to reset onboarding (see it again)
  await prefs.remove('onboarding_complete');
  
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  
  runApp(CroplyAIApp(showOnboarding: !onboardingComplete));
}

class CroplyAIApp extends StatelessWidget {
  final bool showOnboarding;
  
  const CroplyAIApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Croply AI',
      theme: ThemeData(
        primaryColor: const Color(0xFF0F4B06),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F4B06),
          secondary: Color(0xFF15500D),
          surface: Color(0xFFFEFEFE),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F4B06),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF0F4B06),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0F4B06)),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFFEFEFE),
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4B06),
            foregroundColor: const Color(0xFFFFFFFF),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0F4B06),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFEFEFE),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF15500D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0F4B06), width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xFF0F4B06),
          unselectedItemColor: Color(0xFF15500D),
        ),
        useMaterial3: true,
      ),
      initialRoute: showOnboarding ? '/onboarding' : '/login', // Show onboarding on first launch
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const UserLogin(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const HomeWrapper(), // main app after login
        '/upload': (context) => const ImageUploadPage(serviceType: 'default'),
        '/services': (context) => const ServiceSelectionScreen(),
        '/treatment': (context) => const TreatmentRecommendationsPage(
        disease: 'Unknown Disease',
        recommendation: 'No recommendation yet.',
      ),
        '/settings': (context) => const SettingsPage(),
        '/my_crops': (context) => const MyCropsPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Route not found')),
          body: Center(child: Text('No route for ${settings.name}')),
        ),
      ),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 1;

  static const List<Widget> _pages = <Widget>[
    AiAnalysisDashboard(),
    MyCropsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox();
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'My Crops'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
