import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionCard extends StatelessWidget {
  final String category;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final bool isExpense;
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
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color.fromARGB(255, 147, 137, 128).withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row with icon, title, amount
          Row(
            children: [
              // Circle icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [iconColor.withOpacity(0.9), iconColor.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 16.w),

              // Category text
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount Badge
              Container(
                width: 110.w,
                height: 30.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "${isExpense ? '-' : '+'}\$${amount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // View + Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onViewDetails,
                child: Text(
                  "View Details",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF57C00),
                  ),
                ),
              ),
              Row(
                children: [
                  _iconActionButton(Icons.edit, onEdit),
                  SizedBox(width: 10.w),
                  _iconActionButton(
                    Icons.delete,
                    onDelete,
                    bgColor: Colors.red.withOpacity(0.1),
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconActionButton(
    IconData icon,
    VoidCallback? onPressed, {
    Color? bgColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: iconColor ?? Colors.black),
      ),
    );
  }
}
