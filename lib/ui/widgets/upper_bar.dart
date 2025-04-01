import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpperBar extends StatelessWidget implements PreferredSizeWidget {
  const UpperBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Image.asset(
          'assets/img/White_Logo.png',
          height: 60.h,
        ),
      ),
    );
  }
}
