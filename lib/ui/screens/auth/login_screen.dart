// Imports Flutter's core UI toolkit. Required for almost any Flutter screen.
import 'package:flutter/material.dart';

// Allows use of custom fonts from Google Fonts (e.g., Poppins in this screen)
import 'package:google_fonts/google_fonts.dart';

// Adds animation effects like fade, move, etc. to widgets
import 'package:flutter_animate/flutter_animate.dart';

// Enables responsive sizing (like 24.h or 16.sp) for different screen sizes
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Brings in the SignupScreen to navigate to if user doesn’t have an account
import 'package:mohamed222348_expense_tracker/ui/screens/auth/signup_screen.dart';

// Provides the login functionality (usually via Firebase) through a custom AuthService class
import 'package:mohamed222348_expense_tracker/services/auth_service.dart';

// Destination screen after successful login
import 'package:mohamed222348_expense_tracker/ui/screens/home_screen.dart';

// Login screen is a StatefulWidget because it manages user input and loading state
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // super.key helps Flutter identify/rebuild widgets efficiently

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Connects to its mutable state class
}

// This is the mutable state of the LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  // Controllers to read what's typed in the input fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Tracks whether the login button should show a spinner
  bool isLoading = false;

  // Displays a floating message at the bottom of the screen
  void showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent, // Green = success, Red = error
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Main function triggered when the Login button is tapped
  void handleLogin() async {
    // Read and trim the user input from the fields
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Step 1: Validate all fields are filled
    if (email.isEmpty || password.isEmpty) {
      showMessage("Please fill in all fields.");
      return;
    }

    // Step 2: Validate email format
    if (!email.contains("@") || !email.contains(".")) {
      showMessage("Invalid email format.");
      return;
    }

    // Step 3: Validate password length
    if (password.length < 6) {
      showMessage("Password must be at least 6 characters.");
      return;
    }

    // Step 4: Show loading spinner and call login
    setState(() => isLoading = true);

    // Attempt to login via AuthService (likely Firebase)
    final message = await AuthService().login(email: email, password: password);

    // Step 5: Hide spinner
    setState(() => isLoading = false);

    // Step 6: Check if login was successful
    if (message == null) {
      showMessage("Logged in successfully!", isSuccess: true);

      // Short delay to let user see success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Navigate to HomeScreen and remove LoginScreen from back stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } else {
      // If error message returned, show it
      showMessage(message);
    }
  }

  // Required method to describe the UI of this widget
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Provides app bar, body, and background
      backgroundColor: const Color(0xFFF9FAFF), // Light background color
      body: SingleChildScrollView( // Makes screen scrollable on small phones
        child: Padding(
          padding: EdgeInsets.only(bottom: 24.h), // Padding below entire column
          child: Column( // Lays out widgets vertically
            children: [
              // Header section with custom curve and title
              Stack(
                children: [
                  ClipPath( // Clips child with custom shape
                    clipper: CurvedClipper(), // Our wave-shaped clipper class
                    child: Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient( // Orange to Yellow background
                          colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill( // Places text on top of the curve
                    top: 60.h,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins( // Custom font
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h), // Space between header and image
              Image.asset(
                'assets/img/BudgetBuddyLogo.png',
                height: 100.h,
              )
                  .animate() // Adds entrance animation
                  .fadeIn(duration: 1000.ms)
                  .moveY(begin: 30, curve: Curves.easeOut),

              SizedBox(height: 1.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Email and password input fields
                    _inputField(label: "Email", hint: "example@example.com", controller: emailController),
                    _inputField(label: "Password", hint: "Enter your password", isPassword: true, controller: passwordController),

                    SizedBox(height: 20.h),

                    // Login button with animation
                    GestureDetector(
                      onTap: isLoading ? null : handleLogin, // Prevent tap if already loading
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                          ),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white) // Spinner while loading
                              : Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).moveY(begin: 40, curve: Curves.easeOutBack),

                    SizedBox(height: 16.h),

                    // Sign up navigation link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account? ",
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to Signup screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom reusable input field for both email and password
  Widget _inputField({
    required String label, // Field title
    required String hint, // Placeholder
    bool isPassword = false, // Determines if text should be hidden
    required TextEditingController controller, // Controls input value
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14.sp)),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            obscureText: isPassword, // If true, hides password text
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFF57C00)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFF57C00)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper that creates a wave-like shape for header backgrounds
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point in center
      size.width, size.height - 60,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // No need to redraw the clip
}
