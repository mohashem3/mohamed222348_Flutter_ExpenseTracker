// Importing core Flutter packages for building UI and rendering widgets
import 'package:flutter/material.dart';
// Importing screenutil for responsive sizing based on screen dimensions
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Importing Google Fonts for consistent and custom typography across the app
import 'package:google_fonts/google_fonts.dart';
// Importing intl for formatting date objects into readable strings
import 'package:intl/intl.dart';
// Importing custom app bar widget used across screens for visual consistency
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';

// The ViewTransactionScreen is a stateless widget that displays all transaction details in read-only mode
class ViewTransactionScreen extends StatelessWidget {
  // These are the required inputs (passed via constructor) to display the details of a transaction
  final double amount;        // The monetary value of the transaction
  final String category;      // The category label, e.g., "Food", "Travel"
  final String note;          // Optional user-provided note about the transaction
  final DateTime date;        // Date and time of the transaction
  final bool isExpense;       // Flag to determine if it's an expense (true) or income (false)

  // Constructor for initializing the screen with required transaction data
  ViewTransactionScreen({
    super.key,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.isExpense,
  });

  // A color map that links category names to specific colors used for styling icons and UI badges
  final Map<String, Color> categoryColors = {
    'Transport': Colors.deepOrange,
    'Food': Colors.pink,
    'Shopping': Colors.purple,
    'Entertainment': Colors.indigo,
    'Health': Colors.red,
    'Bills': Colors.brown,
    'Travel': Colors.teal,
    'Salary': Colors.green,
    'Freelance': Colors.blue,
    'Business': Colors.amber,
    'Investment': Colors.cyan,
    'Gift': Colors.orange,
    'Other': Colors.grey,
  };

  // A helper method that returns an appropriate icon based on the category name
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Transport':
        return Icons.directions_car;
      case 'Food':
        return Icons.fastfood;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.healing;
      case 'Bills':
        return Icons.receipt_long;
      case 'Travel':
        return Icons.flight;
      case 'Salary':
        return Icons.attach_money;
      case 'Freelance':
        return Icons.laptop_mac;
      case 'Business':
        return Icons.business_center;
      case 'Investment':
        return Icons.trending_up;
      case 'Gift':
        return Icons.card_giftcard;
      case 'Other':
        return Icons.help_outline;
      // If the category doesn't match any predefined case, return a default category icon
      default:
        return Icons.category;
    }
  }

  // A helper method that returns the associated color for a given category, falling back to deep orange
  Color getCategoryColor(String category) {
    return categoryColors[category] ?? const Color(0xFFF57C00);
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Set a light background color to maintain a clean and modern appearance
    backgroundColor: const Color(0xFFF9FAFF),

    // Use a custom top app bar widget (defined elsewhere in the project)
    appBar: const UpperBar(),

    // Add padding around the main body content for better spacing on both sides
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),

      // Enable vertical scrolling in case content overflows on smaller screens
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30.h),

        // All visual content is placed inside a vertical column
        child: Column(
          children: [
            // Main heading/title of the screen
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 20.sp, // Responsive font size using ScreenUtil
                fontWeight: FontWeight.w600, // Semi-bold for emphasis
                color: Colors.black87, // Slightly lighter black for better UX
              ),
            ),

            SizedBox(height: 24.h), // Spacing after the title

            // First field showing whether it's an income or expense
            _readonlyField(
              icon: Icons.account_balance_wallet, // Wallet icon for transaction type
              label: isExpense ? "Expense" : "Income", // Dynamic label based on boolean flag
              iconColor: isExpense ? Colors.red : Colors.green, // Red = Expense, Green = Income
            ),

            SizedBox(height: 20.h), // Vertical spacing between fields

            // Display the transaction amount in a custom styled container
            _amountDisplay(),

            SizedBox(height: 20.h), // Vertical spacing

            // Display the transaction category with a contextual icon and color
            _readonlyField(
              icon: getCategoryIcon(category), // Returns the correct icon for the category
              label: category, // Displays the category name text
              iconColor: getCategoryColor(category), // Uses matching color from category map
            ),

            SizedBox(height: 20.h),

            // Display the optional note entered by the user; allow multi-line text display
            _readonlyField(
              icon: Icons.edit_note,
              label: note,
              maxLines: 6, // Allow note to span multiple lines
              minHeight: 100.h, // Minimum height to create a larger text box layout
            ),

            SizedBox(height: 20.h),

            // Display the transaction date formatted as "yyyy-MM-dd"
            _readonlyField(
              icon: Icons.calendar_today,
              label: DateFormat('yyyy-MM-dd').format(date), // Formats date object to string
            ),
          ],
        ),
      ),
    ),
  );
}


 // Widget to display the transaction amount in a highlighted and styled box
Widget _amountDisplay() {
  return Container(
    height: 80.h, // Fixed height for the amount display container
    padding: EdgeInsets.symmetric(horizontal: 24.w), // Horizontal internal spacing
    decoration: BoxDecoration(
      color: Colors.white, // Background color of the container
      borderRadius: BorderRadius.circular(40.r), // Fully rounded edges for premium look
      border: Border.all(
        color: Colors.orange.withAlpha((0.4 * 255).toInt()), // Semi-transparent orange border
        width: 1.2, // Border thickness
      ),
    ),
    child: Row(
      children: [
        // Dollar sign placed before the actual number
        Text(
          "\$",
          style: GoogleFonts.poppins(
            fontSize: 22.sp, // Font size for the currency symbol
            color: Colors.black54, // Slightly muted black
          ),
        ),
        SizedBox(width: 12.w), // Spacing between dollar sign and amount text

        // The actual amount value displayed in a gradient color
        Expanded(
          child: ShaderMask(
            // Applies a gradient color effect to the text
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange to light yellow
            ).createShader(bounds),
            blendMode: BlendMode.srcIn, // Ensures the gradient applies only to text color
            child: Text(
              amount.toStringAsFixed(2), // Formats the amount with 2 decimal places
              textAlign: TextAlign.center, // Centers the text horizontally
              style: GoogleFonts.poppins(
                fontSize: 36.sp, // Large font size to emphasize amount
                fontWeight: FontWeight.w700, // Bold weight
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Reusable widget for rendering a read-only information field with an icon
Widget _readonlyField({
  required IconData icon, // Icon to display on the left side
  required String label,  // The main text content to show
  int maxLines = 1,       // Number of text lines before overflow
  double minHeight = 0,   // Optional minimum height for taller fields like notes
  Color iconColor = const Color(0xFFF57C00), // Default icon and border color
}) {
  return Container(
    constraints: BoxConstraints(minHeight: minHeight), // Allows flexibility for multiline fields
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h), // Internal padding
    decoration: BoxDecoration(
      color: Colors.white, // Background color
      borderRadius: BorderRadius.circular(16.r), // Rounded corners for field
      border: Border.all(
        color: iconColor.withAlpha((0.3 * 255).toInt()), // Lightly colored border for subtle effect
        width: 1, // Border thickness
      ),
    ),
    child: Row(
      // Align text top or center depending on line count
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start // For multi-line fields (e.g. notes)
          : CrossAxisAlignment.center, // For single-line fields
      children: [
        // Circular icon container with gradient background
        Container(
          padding: EdgeInsets.all(6.w), // Inner padding around icon
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                iconColor.withAlpha((0.9 * 255).toInt()), // Stronger base color
                iconColor.withAlpha((0.5 * 255).toInt()), // Lighter gradient
              ],
            ),
          ),
          child: Icon(
            icon,
            size: 18.sp, // Icon size
            color: Colors.white, // Icon color inside gradient circle
          ),
        ),

        SizedBox(width: 12.w), // Spacing between icon and text

        // The actual label content (e.g., category name, note, date)
        Expanded(
          child: Text(
            label,
            maxLines: maxLines, // Respect the max line setting
            overflow: TextOverflow.ellipsis, // Clip long text with ellipsis
            style: GoogleFonts.poppins(fontSize: 14.sp), // Text styling
          ),
        ),
      ],
    ),
  );
}
}