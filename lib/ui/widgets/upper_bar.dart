import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// A custom AppBar widget with a gradient background and centered logo.
// It implements PreferredSizeWidget so it can be used directly in the `appBar` parameter of a Scaffold.
class UpperBar extends StatelessWidget implements PreferredSizeWidget {
  const UpperBar({super.key});

  // This tells Flutter the preferred height of the AppBar, needed because we're using a custom widget.
  @override
  Size get preferredSize => Size.fromHeight(70.h); // Responsive height using ScreenUtil

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0, // Removes shadow for a flat look
      centerTitle: true, // Ensures the logo is centered horizontally in the AppBar

      // `flexibleSpace` allows for custom background styling such as gradients or images.
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Smooth orange-to-yellow gradient
            begin: Alignment.topRight,   // Starts from top-right
            end: Alignment.bottomLeft,   // Ends at bottom-left to create a diagonal effect
          ),
        ),
      ),

      // The title here is an image logo rather than text.
      title: Padding(
        padding: EdgeInsets.only(top: 2.h), // Slight top padding to vertically center the logo
        child: Image.asset(
          'assets/img/White_Logo.png', // Path to the logo asset
          height: 60.h, // Responsive height for the logo image
        ),
      ),
    );
  }
}
