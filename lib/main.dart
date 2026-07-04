import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob only on mobile native
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob Init Error: \$e');
    }
  }
  
  // Force portrait mode for a slicker controlled UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()..fetchCategories()..fetchTransactions()),
      ],
      child: const FinancialNotesApp(),
    ),
  );
}

class FinancialNotesApp extends StatelessWidget {
  const FinancialNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        primaryColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4F46E5), // Indigo
          secondary: Color(0xFF10B981), // Emerald
          surface: Colors.white,
          error: Color(0xFFEF4444), // Rose
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFF1E293B), // Slate 800
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Indigo light
          secondary: Color(0xFF34D399), // Emerald light
          surface: Color(0xFF1E293B),
          error: Color(0xFFF87171),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system, // Dynamically switches based on OS setting
      home: const HomeScreen(),
    );
  }
}
