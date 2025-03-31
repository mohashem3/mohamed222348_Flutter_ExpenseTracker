  import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BudgetBuddy Home',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Text(
          'Welcome to BudgetBuddy!',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}
