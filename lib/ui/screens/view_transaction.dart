import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';

class ViewTransactionScreen extends StatelessWidget {
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final bool isExpense;

  const ViewTransactionScreen({
    super.key,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: const UpperBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            children: [
              Text(
                'Transaction Details',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),
              _readonlyField(
                icon: Icons.account_balance_wallet,
                label: isExpense ? "Expense" : "Income",
                iconColor: isExpense ? Colors.red : Colors.green,
              ),
              SizedBox(height: 20.h),
              _amountDisplay(),
              SizedBox(height: 20.h),
              _readonlyField(icon: Icons.category, label: category),
              SizedBox(height: 20.h),
              _readonlyField(
                icon: Icons.edit_note,
                label: note,
                maxLines: 6,
                minHeight: 100.h,
              ),
              SizedBox(height: 20.h),
              _readonlyField(
                icon: Icons.calendar_today,
                label: DateFormat('yyyy-MM-dd').format(date),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountDisplay() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Text(
            "\$",
            style: GoogleFonts.poppins(fontSize: 22.sp, color: Colors.black54),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                amount.toStringAsFixed(2),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 36.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField({
    required IconData icon,
    required String label,
    int maxLines = 1,
    double minHeight = 0,
    Color iconColor = const Color(0xFFF57C00),
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [iconColor.withOpacity(0.9), iconColor.withOpacity(0.5)],
              ),
            ),
            child: Icon(icon, size: 18.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
