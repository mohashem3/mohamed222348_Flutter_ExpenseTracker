import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Stateless widget used to present a compact filter menu via a popup
class FilterTransaction extends StatelessWidget {
  final String selectedFilter; // The currently selected filter option
  final ValueChanged<String> onFilterChanged; // Callback to notify parent widget when a new filter is selected

  const FilterTransaction({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // List of available filtering options that will appear in the popup menu
    final List<String> filters = [
      'Newest',        // Sort transactions by most recent date first
      'Oldest',        // Sort by oldest date first
      'Amount ↑',      // Sort by highest amount first
      'Amount ↓',      // Sort by lowest amount first
      'This Month',    // Filter only transactions from current month
      'This Year',     // Filter only transactions from current year
      'Last 7 Days',   // Filter only transactions from the past week
    ];

    return Container(
      height: 46.h, // Fixed height, responsive via screenutil
      width: 46.h,  // Width same as height for a square shape
      decoration: BoxDecoration(
        color: Colors.white, // Base color of the filter button
        borderRadius: BorderRadius.circular(14.r), // Rounded edges for soft UI
        border: Border.all(color: Colors.grey.shade700), // Subtle border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.12 * 255).toInt()), // Light drop shadow for elevation effect
            blurRadius: 10, // Soft blur radius
            offset: const Offset(0, 4), // Drops shadow slightly downward
          )
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: onFilterChanged, // When a filter is selected, notify parent via callback
        icon: const Icon(Icons.tune, color: Colors.grey), // Tune icon represents filtering
        itemBuilder: (BuildContext context) {
          // Convert each string filter into a popup menu item
          return filters.map((filter) {
            return PopupMenuItem<String>(
              value: filter, // Return this value when selected
              child: Text(filter), // Displayed text inside the menu
            );
          }).toList(); // Return a list of all popup items
        },
      ),
    );
  }
}
