import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterTransaction extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterTransaction({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> filters = [
      'Newest',
      'Oldest',
      'Amount ↑',
      'Amount ↓',
      'This Month',
      'This Year',
      'Last 7 Days',
    ];

    return Container(
      height: 46.h,
      width: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade700),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: onFilterChanged,
        icon: const Icon(Icons.tune, color: Colors.grey),
        itemBuilder: (BuildContext context) {
          return filters.map((filter) {
            return PopupMenuItem<String>(
              value: filter,
              child: Text(filter),
            );
          }).toList();
        },
      ),
    );
  }
}
