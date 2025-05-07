import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// The WelcomeScreen is the initial screen shown to users when the app is launched.
// It contains branding, a subtitle, and navigation options to sign up or log in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Sets a soft light background for the screen
      body: Stack(
        children: [
          // Background floating icons for visual design enhancement
          ..._buildFloatingIcons(context),

          // Foreground UI components: logo, subtitle, buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w), // Horizontal margin for content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically in the screen
              children: [
                const Spacer(), // Pushes the logo and subtitle slightly down

                // App logo image loaded from assets
                Image.asset(
                  'assets/img/BudgetBuddyLogo.png', // Ensure this path exists in assets folder
                  height: 130.h, // Responsive height using ScreenUtil
                ),

                SizedBox(height: 20.h), // Space between logo and subtitle

                // App subtitle or slogan
                Text(
                  "Take control of your spending and manage your money like a pro.",
                  textAlign: TextAlign.center, // Center-aligns text in the screen
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700, // Uses a mid-grey tone for better readability
                  ),
                ),

                const Spacer(), // Pushes buttons to the lower part of the screen

                // Main action button to navigate to sign-up screen
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'), // Navigates to /signup route
                  child: Container(
                    width: double.infinity, // Button stretches full width
                    height: 54.h, // Responsive height
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange to yellow gradient
                      ),
                      borderRadius: BorderRadius.circular(28.r), // Rounded corners for the button
                    ),
                    child: Center(
                      child: Text(
                        "Get Started", // Button text
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text on gradient background
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h), // Spacing between buttons

                // Secondary button for users who already have an account
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'), // Navigates to /login route
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF57C00)), // Orange outline color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r), // Same border radius as primary button
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h), // Padding inside the button
                    minimumSize: Size(double.infinity, 54.h), // Full width with fixed height
                  ),
                  child: Text(
                    "I have an account", // Button text
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      color: const Color(0xFFF57C00), // Orange text matching the theme
                    ),
                  ),
                ),

                SizedBox(height: 30.h), // Final bottom padding below buttons
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Private method to generate a list of floating icon widgets for decorative background
  List<Widget> _buildFloatingIcons(BuildContext context) {
    // Predefined list of icons related to money and finance
    final icons = [
      Icons.account_balance_wallet,
      Icons.attach_money,
      Icons.savings,
      Icons.credit_card,
      Icons.monetization_on,
    ];

    // Color palette for floating icons
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.deepOrange,
    ];

    // Hardcoded positions (x, y) for each floating icon in the background
    final positions = [
      const Offset(30, 60),
      const Offset(280, 100),
      const Offset(20, 180),
      const Offset(80, 330),
      const Offset(10, 520),
      const Offset(250, 520),
      const Offset(160, 640),
      const Offset(280, 440),
    ];

    // Generate Positioned icons with opacity and styling using a loop
    return List.generate(positions.length, (i) {
      return Positioned(
        top: positions[i].dy.h, // Vertical position with screen responsiveness
        left: positions[i].dx.w, // Horizontal position with screen responsiveness
        child: Opacity(
          opacity: 0.18, // Light transparency for subtle background effect
          child: Icon(
            icons[i % icons.length], // Cycles through available icons
            size: 72.sp, // Responsive icon size
            color: colors[i % colors.length], // Cycles through color palette
          ),
        ),
      );
    });
  }
}
