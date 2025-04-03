import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/auth/login_screen.dart';
import 'package:mohamed222348_expense_tracker/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void handleSignup() async {
  String name = nameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  // Local validation
  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    showMessage("Please fill in all fields.");
    return;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    showMessage("Enter a valid email address.");
    return;
  }

  if (password.length < 6) {
    showMessage("Password must be at least 6 characters.");
    return;
  }

  setState(() => isLoading = true);

  final message = await AuthService().signUp(
    name: name,
    email: email,
    password: password,
  );

  setState(() => isLoading = false);

  if (message == null) {
    showMessage("Account created successfully!", isSuccess: true);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  } else {
    showMessage(message);
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              // Header
              Stack(
                children: [
                  ClipPath(
                    clipper: CurvedClipper(),
                    child: Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 60.h,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),
              Image.asset(
                'assets/img/BudgetBuddyLogo.png',
                height: 100.h,
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .moveY(begin: 30, curve: Curves.easeOut),

              SizedBox(height: 1.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    _inputField(label: "Name", hint: "John Doe", controller: nameController),
                    _inputField(label: "Email", hint: "example@example.com", controller: emailController),
                    _inputField(label: "Password", hint: "6+ Characters", isPassword: true, controller: passwordController),

                    SizedBox(height: 20.h),

                    // Button
                    GestureDetector(
                      onTap: isLoading ? null : handleSignup,
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
                              ? const CircularProgressIndicator(color: Colors.white)
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

                    SizedBox(height: 16.h),

                    // Log In link
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

  Widget _inputField({
    required String label,
    required String hint,
    bool isPassword = false,
    required TextEditingController controller,
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
            obscureText: isPassword,
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



// Custom clipper for top wave
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2, size.height, // ⬅️ Centered control point
      size.width, size.height - 60,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


