import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// This widget represents a styled search input used to filter the transaction list in real-time.
class SearchTransaction extends StatelessWidget {
  final ValueChanged<String> onSearch; // Callback function that notifies parent when the user types

  const SearchTransaction({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w, // Fixed responsive width using screenutil
      padding: EdgeInsets.symmetric(horizontal: 14.w), // Horizontal internal padding
      decoration: BoxDecoration(
        color: Colors.white, // White background for clean look
        borderRadius: BorderRadius.circular(14.r), // Rounded corners for modern UI
        border: Border.all(color: Colors.grey.shade700), // Subtle border for contrast
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.12 * 255).toInt()), // Light shadow for depth
            blurRadius: 10, // Soft blur
            offset: const Offset(0, 4), // Positioned below the container
          )
        ],
      ),
      child: TextField(
        onChanged: onSearch, // Called every time the user types (used for live search filtering)
        style: GoogleFonts.poppins(fontSize: 14.sp), // Use custom font for consistency
        textAlignVertical: TextAlignVertical.center, // Aligns text vertically within the field
        decoration: InputDecoration(
          border: InputBorder.none, // Removes default underline border
          hintText: 'Search transactions...', // Placeholder text shown when empty
          hintStyle: GoogleFonts.poppins(color: Colors.grey), // Style for placeholder
          prefixIcon: const Icon(Icons.search, color: Colors.grey), // Search icon on the left
        ),
      ),
    );
  }
}
