// Importing Flutter's core material UI components
import 'package:flutter/material.dart';
// Google Fonts for custom font styles
import 'package:google_fonts/google_fonts.dart';
// Flutter Animate for smooth animations
import 'package:flutter_animate/flutter_animate.dart';
// For screen size scaling (responsive UI)
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Import login screen for navigation after successful signup
import 'package:mohamed222348_expense_tracker/ui/screens/auth/login_screen.dart';
// Import AuthService class to handle Firebase sign up
import 'package:mohamed222348_expense_tracker/services/auth_service.dart';

// A stateful widget because signup screen UI will change (e.g., loading state)
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key}); // 'key' is used for widget identity management

  @override
  State<SignupScreen> createState() => _SignupScreenState(); // Creates the mutable state
}

// This class holds the logic and mutable UI state for SignupScreen
class _SignupScreenState extends State<SignupScreen> {
  // TextEditingControllers to read input from TextFields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Boolean flag to control loading spinner visibility
  bool isLoading = false;

  // Function triggered when user taps on the signup button
  void handleSignup() async {
    // Read and trim the input text
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check for empty fields
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage("Please fill in all fields.");
      return;
    }

    // Basic email validation using regular expression
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showMessage("Enter a valid email address.");
      return;
    }

    // Check password length
    if (password.length < 6) {
      showMessage("Password must be at least 6 characters.");
      return;
    }

    // Show loading spinner
    setState(() => isLoading = true);

    // Call signup method from AuthService
    final message = await AuthService().signUp(
      name: name,
      email: email,
      password: password,
    );

    // Hide loading spinner
    setState(() => isLoading = false);

    if (message == null) {
      // Signup successful
      showMessage("Account created successfully!", isSuccess: true);

      // Wait for a moment, then navigate to login screen
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      // Show error message
      showMessage(message);
    }
  }

  // Show a snackbar message at the bottom of the screen
  void showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // The build() method describes the UI of this screen.
  // It returns a widget (usually starting with Scaffold) that tells Flutter what to display.
  // 'BuildContext context' gives access to the widget tree, theme, screen size, and navigation.
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Provides basic screen layout (background, body, etc.)
      backgroundColor: const Color(0xFFF9FAFF),
      body: SingleChildScrollView( // Makes screen scrollable on small devices
        child: Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column( // Arranges widgets vertically
            children: [
              // Header section with curved background and title
              Stack( // Allows overlapping widgets
                children: [
                  ClipPath( // Clips the background into a custom wave shape
                    clipper: CurvedClipper(), // Our custom clipper class
                    child: Container( // Box for background color
                      height: 180.h,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient( // Orange-to-yellow gradient
                          colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill( // Positions the title text over the wave
                    top: 60.h,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins( // Styled font
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h), // Spacer

              Image.asset( // Loads image from assets folder
                'assets/img/BudgetBuddyLogo.png',
                height: 100.h,
              )
                  .animate() // Animates appearance
                  .fadeIn(duration: 1000.ms)
                  .moveY(begin: 30, curve: Curves.easeOut),

              SizedBox(height: 1.h), // Spacer

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w), // Adds side padding
                child: Column(
                  children: [
                    // 3 Input fields using the custom _inputField widget
                    _inputField(label: "Name", hint: "John Doe", controller: nameController),
                    _inputField(label: "Email", hint: "example@example.com", controller: emailController),
                    _inputField(label: "Password", hint: "6+ Characters", isPassword: true, controller: passwordController),

                    SizedBox(height: 20.h), // Spacer

                    // Sign up button with animation
                    GestureDetector(
                      onTap: isLoading ? null : handleSignup, // Tap triggers signup
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration( // Gradient + rounded button
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                          ),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white) // Show spinner if loading
                              : Text(
                                  'Create an Account',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).moveY(begin: 40, curve: Curves.easeOutBack),

                    SizedBox(height: 16.h), // Spacer

                    // Link to go to Login screen
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Log In",
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

  // Custom widget that builds a styled text field
  Widget _inputField({
    required String label, // Label shown above field
    required String hint, // Hint inside the field
    bool isPassword = false, // Should hide text?
    required TextEditingController controller, // Controls input
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h), // Space above and below
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14.sp)), // Label text
          SizedBox(height: 6.h),
          TextField( // Input field
            controller: controller,
            obscureText: isPassword, // Hide if password
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

// Custom clipper class to create a curved wave shape at the top
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point is in the middle bottom
      size.width, size.height - 60,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // No need to reclip
}
