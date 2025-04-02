import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: Stack(
        children: [
          // 💸 Scattered money icons (more + increased visibility)
          ..._buildFloatingIcons(context),

          // 🌟 Foreground
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ✅ Bigger logo image
                Image.asset(
                  'assets/img/BudgetBuddyLogo.png',
                  height: 130.h,
                ),

                SizedBox(height: 20.h),

                // Subtitle
                Text(
                  "Take control of your spending and manage your money like a pro.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),

                const Spacer(),

                // 🌈 Gradient button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                      ),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Center(
                      child: Text(
                        "Get Started",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Outlined "I have an account"
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF57C00)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    minimumSize: Size(double.infinity, 54.h),
                  ),
                  child: Text(
                    "I have an account",
                    style: GoogleFonts.poppins(fontSize: 15.sp, color: const Color(0xFFF57C00)),
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Helper to generate floating money icons
  List<Widget> _buildFloatingIcons(BuildContext context) {
    final icons = [
      Icons.account_balance_wallet,
      Icons.attach_money,
      Icons.savings,
      Icons.credit_card,
      Icons.monetization_on,
    ];

    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.deepOrange,
    ];

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

    return List.generate(positions.length, (i) {
      return Positioned(
        top: positions[i].dy.h,
        left: positions[i].dx.w,
        child: Opacity(
          opacity: 0.18,
          child: Icon(
            icons[i % icons.length],
            size: 72.sp,
            color: colors[i % colors.length],
          ),
        ),
      );
    });
  }
}
