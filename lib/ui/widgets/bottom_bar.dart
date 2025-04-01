import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onFabPressed;

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
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 0,
        color: Colors.transparent, // Make transparent to show Container background
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(icon: Icons.home, index: 0),
              _navItem(icon: Icons.search, index: 1),
              SizedBox(width: 56.w), // Reserved space for FAB
              _navItem(icon: Icons.list_alt, index: 3),
              _navItem(icon: Icons.person, index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Icon(
        icon,
        size: 26.sp,
        color: currentIndex == index ? const Color(0xFFF57C00) : Colors.grey.shade500,
      ),
    );
  }
}

class CenterFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CenterFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
