import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

// Import all necessary UI screens and models used in the app
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/transaction_list.dart';
import 'ui/screens/add_transaction.dart';
import 'ui/screens/welcome_screen.dart'; // Welcome screen shown at app launch
import 'model/transaction_model.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/stats_screen.dart';

/// Entry point of the Flutter application.
void main() async {
  // Ensures all widgets are properly bound before performing async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase, which is required before any Firebase service (e.g., Firestore/Auth) is used
  await Firebase.initializeApp();

  // Starts the main Flutter application
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Reference design dimensions for responsive UI scaling
      minTextAdapt: true, // Adjusts text size responsively for smaller screens
      splitScreenMode: true, // Allows support for split-screen mode
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Removes debug banner from top-right corner
          title: 'BudgetBuddy', // Sets the application name
          theme: ThemeData(
            useMaterial3: true, // Enables Material 3 design components
            scaffoldBackgroundColor: const Color(0xFFF9F9FB), // Global background color
            fontFamily: 'Poppins', // Sets the global font to Poppins
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), // Defines primary theme color
          ),
          initialRoute: '/welcome', // The first screen the user sees when app starts
          
          // Static route definitions for all main screens
          routes: {
            '/welcome': (_) => const WelcomeScreen(), // Introductory landing screen
            '/signup': (context) => const SignupScreen(), // Account registration screen
            '/login': (context) => const LoginScreen(), // Account login screen
            '/home': (context) => const HomeScreen(), // Main dashboard after login
            '/list': (_) => const TransactionListScreen(), // Full list of user transactions
            '/profile': (_) => const ProfileScreen(), // User profile and settings screen
            '/stats': (_) => const StatsScreen(), // Visual stats and charts for analytics
          },

          // Dynamic route generation for screens that require arguments
          onGenerateRoute: (settings) {
            // Handles navigation to the Add Transaction screen with optional transaction data for editing
            if (settings.name == '/add') {
              final transaction = settings.arguments as TransactionModel?; // Extract transaction if passed
              return MaterialPageRoute(
                builder: (_) => AddTransactionScreen(transaction: transaction),
              );
            }
            return null; // Returns null if no matching dynamic route is found
          },
        );
      },
    );
  }
}
