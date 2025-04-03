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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color.fromARGB(255, 147, 137, 128).withAlpha((0.2 * 255).toInt()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.12 * 255).toInt()),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon, category, amount
          Row(
            children: [
              Container(
  width: 40.w,
  height: 40.w,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: iconColor.withAlpha((0.20 * 255).toInt()), // soft pastel bg
  ),
  child: Icon(icon, color: iconColor, size: 20.sp), // vibrant icon
),

              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 110.w,
                height: 30.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isExpense ? Colors.red.withAlpha((0.1 * 255).toInt()) : Colors.green.withAlpha((0.1 * 255).toInt()),
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
          // Bottom row: Date/Time badge + Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  DateFormat('dd MMM, h:mm a').format(dateTime),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              Row(
                children: [
                  _iconActionButton(Icons.info_outline, onViewDetails, bgColor: Colors.blue.shade50, iconColor: Colors.blue),
                  SizedBox(width: 10.w),
                  _iconActionButton(Icons.edit, onEdit),
                  SizedBox(width: 10.w),
                  _iconActionButton(
                    Icons.delete,
                    onDelete,
                    bgColor: Colors.red.withAlpha((0.1 * 255).toInt()),
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
