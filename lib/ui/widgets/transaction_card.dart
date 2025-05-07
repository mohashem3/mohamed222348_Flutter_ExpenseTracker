import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final String category;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final bool isExpense;
  final DateTime dateTime;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;

  const TransactionCard({
    super.key,
    required this.category,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.isExpense,
    required this.dateTime,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
  });

  @override
Widget build(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h), // Adds vertical spacing between cards
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h), // Inner padding for content spacing
    decoration: BoxDecoration(
      color: Colors.white, // Card background color
      borderRadius: BorderRadius.circular(20.r), // Rounded edges for modern design
      border: Border.all(
        color: const Color.fromARGB(255, 147, 137, 128).withAlpha((0.2 * 255).toInt()), // Soft border tone for visual separation
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.12 * 255).toInt()), // Subtle shadow for depth
          blurRadius: 18, // Spread of blur
          spreadRadius: 1, // Slight expansion of shadow beyond bounds
          offset: const Offset(0, 6), // Positioned shadow downward
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns child widgets to the left
      children: [
        // Row for transaction's main info: icon, category name, and amount
        Row(
          children: [
            // Circular icon container representing the transaction category
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withAlpha((0.20 * 255).toInt()), // Faint background tint of the icon color
              ),
              child: Icon(
                icon,
                color: iconColor, // Icon uses the color tied to its category
                size: 20.sp,
              ),
            ),

            SizedBox(width: 16.w), // Horizontal spacing between icon and text

            // Displays the category name with moderate weight
            Expanded(
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Right-aligned amount display with colored background (green for income, red for expense)
            Container(
              width: 110.w,
              height: 30.h,
              alignment: Alignment.center, // Center aligns the text inside the badge
              decoration: BoxDecoration(
                color: isExpense
                    ? Colors.red.withAlpha((0.1 * 255).toInt())
                    : Colors.green.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12.r), // Rounded pill shape
              ),
              child: Text(
                "${isExpense ? '-' : '+'}\$${amount.toStringAsFixed(2)}", // Display sign and formatted amount
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isExpense ? Colors.red : Colors.green, // Text color matches transaction type
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h), // Space between this row and the next section of the card

          // Bottom row: Date/Time badge + Action Icons
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns date to the left and actions to the right
  children: [
    // Left-aligned date/time badge for when the transaction was created
    Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), // Inner padding for visual clarity
      decoration: BoxDecoration(
        color: Colors.orange.shade50, // Light orange background for subtle emphasis
        borderRadius: BorderRadius.circular(10.r), // Rounded edges for badge-like appearance
      ),
      child: Text(
        DateFormat('dd MMM, h:mm a').format(dateTime), // Formats date to readable form (e.g., 05 May, 2:30 PM)
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.orange.shade700, // Uses a deeper orange for contrast against background
        ),
      ),
    ),

    // Right-aligned action icons: view, edit, delete
    Row(
      children: [
        // View Details button (blue color scheme for information)
        _iconActionButton(
          Icons.info_outline,
          onViewDetails,
          bgColor: Colors.blue.shade50,
          iconColor: Colors.blue,
        ),
        SizedBox(width: 10.w), // Space between icons

        // Edit button (uses default theme color, likely orange)
        _iconActionButton(Icons.edit, onEdit),

        SizedBox(width: 10.w), // Space between icons

        // Delete button (uses red theme to indicate destructive action)
        _iconActionButton(
          Icons.delete,
          onDelete,
          bgColor: Colors.red.withAlpha((0.1 * 255).toInt()), // Light red background for soft warning tone
          iconColor: Colors.red, // Strong red icon for immediate recognition
        ),
      ],
    ),
  ],
),
        ],
      ),
    );
  }

  // Reusable widget for circular action icons (e.g., info, edit, delete)
Widget _iconActionButton(
  IconData icon, // Icon to be displayed (e.g., Icons.edit)
  VoidCallback? onPressed, // Callback triggered when user taps the icon
  {
    Color? bgColor,   // Optional background color for the circular icon
    Color? iconColor, // Optional icon color
  }
) {
  return GestureDetector(
    onTap: onPressed, // When the icon is tapped, trigger the provided callback
    child: Container(
      padding: EdgeInsets.all(6.w), // Internal spacing around the icon
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade200, // Default to light grey if no background color is provided
        shape: BoxShape.circle, // Makes the button circular in shape
      ),
      child: Icon(
        icon,                         // Icon type to render (passed as parameter)
        size: 18.sp,                  // Scaled size for responsiveness
        color: iconColor ?? Colors.black, // Defaults to black if no icon color is provided
      ),
    ),
  );
}
}
