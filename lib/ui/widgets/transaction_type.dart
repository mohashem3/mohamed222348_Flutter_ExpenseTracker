import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// A custom toggle switch used to select between "Income" and "Expenses"
// It is used in Add/Edit transaction screens or filters to change transaction type
class TransactionTypeSwitch extends StatelessWidget {
  final bool isExpense; // Indicates the current selected type: true for Expense, false for Income
  final ValueChanged<bool> onToggle; // Callback function to notify parent when the switch is toggled

  const TransactionTypeSwitch({
    super.key,
    required this.isExpense,   // Passed from parent to track current state
    required this.onToggle,    // Triggered when user taps a tab
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h, // Height of the switch container, responsive with screenutil
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r), // Rounded edges for pill shape
        border: Border.all(
          color: const Color(0xFFF57C00).withAlpha((0.4 * 255).toInt()), // Soft orange border
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _buildTab("Income", !isExpense),  // Left tab: active when isExpense is false
          _buildTab("Expenses", isExpense), // Right tab: active when isExpense is true
        ],
      ),
    );
  }

  // Builds one side of the toggle tab (either Income or Expenses)
  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onToggle(label == "Expenses"), // On tap, notify parent with new selection
        child: Container(
          height: double.infinity, // Fills the height of the parent container
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(40.r), // Rounded corner when active
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange gradient when selected
                  ),
                )
              : const BoxDecoration(), // No decoration when inactive
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey, // White text when active, grey otherwise
              ),
            ),
          ),
        ),
      ),
    );
  }
}
