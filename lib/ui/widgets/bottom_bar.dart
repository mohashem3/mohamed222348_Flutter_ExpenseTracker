import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// BottomBar widget represents the bottom navigation bar of the app
class BottomBar extends StatelessWidget {
  final int currentIndex; // Index of the currently selected tab
  final Function(int) onTabSelected; // Callback when a tab icon is tapped
  final VoidCallback onFabPressed; // Callback when the floating action button is pressed

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Base background color of the navigation bar
        border: const Border(
          top: BorderSide(color: Colors.black12, width: 1), // Subtle top border line
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()), // Very soft shadow
            blurRadius: 12, // Spread of the shadow blur
            offset: const Offset(0, -3), // Shadow cast slightly upward
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Creates a notch for the FAB
        notchMargin: 8, // Space between the FAB and the notch
        elevation: 0, // Elevation disabled since we're using a custom shadow
        color: Colors.transparent, // Transparent to allow outer Container background to show
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Horizontal and vertical internal spacing
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space icons evenly, with a FAB gap in the center
            children: [
              _navItem(icon: Icons.home, index: 0),       // Home tab
              _navItem(icon: Icons.bar_chart, index: 1),   // Stats tab
              SizedBox(width: 56.w),                       // Spacer for center FAB
              _navItem(icon: Icons.list_alt, index: 3),    // Transactions tab
              _navItem(icon: Icons.person, index: 2),      // Profile tab
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to generate each navigation icon with active state styling
  Widget _navItem({required IconData icon, required int index}) {
    return GestureDetector(
      onTap: () => onTabSelected(index), // Invoke callback with selected tab index
      child: Icon(
        icon,
        size: 26.sp, // Responsive icon size
        color: currentIndex == index
            ? const Color(0xFFF57C00) // Highlight current tab with primary theme color
            : Colors.grey.shade500,   // Inactive tabs use muted grey color
      ),
    );
  }
}

// CenterFAB represents the centrally placed floating action button
class CenterFAB extends StatelessWidget {
  final VoidCallback onPressed; // Callback when FAB is tapped

  const CenterFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w, // Width of FAB container (responsive)
      height: 64.w, // Height equal to width for perfect circle
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Makes the FAB container circular
        gradient: const LinearGradient(
          colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange to yellow gradient
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha((0.4 * 255).toInt()), // Subtle orange glow effect
            blurRadius: 8, // Amount of blur applied to the shadow
            offset: const Offset(0, 4), // Shadow drops downward slightly
          ),
        ],
      ),
      child: RawMaterialButton(
        onPressed: onPressed, // Invokes the provided callback when pressed
        shape: const CircleBorder(), // Maintains circular clickable area
        child: const Icon(
          Icons.add,
          color: Colors.white, // White "+" icon inside the FAB
          size: 28, // Fixed icon size for consistency
        ),
      ),
    );
  }
}
