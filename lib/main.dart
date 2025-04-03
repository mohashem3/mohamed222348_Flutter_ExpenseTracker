import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/transaction_list.dart';
import 'ui/screens/add_transaction.dart';
import 'ui/screens/welcome_screen.dart'; // ✅ Import welcome screen
import 'model/transaction_model.dart';
import 'ui/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BudgetBuddy',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF9F9FB),
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          initialRoute: '/welcome', // ✅ Updated initial route
          routes: {
            '/welcome': (_) => const WelcomeScreen(), // ✅ New welcome route
            '/signup': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/list': (_) => const TransactionListScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
          // ✅ Enable dynamic routing with arguments
          onGenerateRoute: (settings) {
            if (settings.name == '/add') {
              final transaction = settings.arguments as TransactionModel?;
              return MaterialPageRoute(
                builder: (_) => AddTransactionScreen(transaction: transaction),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
