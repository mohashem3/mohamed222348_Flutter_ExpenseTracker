import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mohamed222348_expense_tracker/services/auth_service.dart';
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/add_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/auth/login_screen.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  String userName = '';
  String userInitials = '';

  double income = 0;
  double expense = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadTotals();
  }

  Future<void> _loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final name = doc['name'] ?? 'User';
      final initials = _getInitials(name);
      setState(() {
        userName = name;
        userInitials = initials;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  }

  Future<void> _loadTotals() async {
    final totals = await TransactionService().calculateTotals();
    setState(() {
      income = totals['income'] ?? 0;
      expense = totals['expense'] ?? 0;
      balance = income - expense;
    });
  }

  void _onTabSelected(int index) {
    setState(() => selectedIndex = index);
    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/list');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UpperBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        userInitials,
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome!', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                        Text(userName.isNotEmpty ? userName : 'User',
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    await AuthService().logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.deepOrange),
                )
              ],
            ),

            SizedBox(height: 20.h),

            // Gradient Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF8E2DE2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text("Total Balance", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.sp)),
                  SizedBox(height: 4.h),
                  Text(
                    "\$${balance.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text("\$${income.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text("\$${expense.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Transactions Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transactions", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/list'),
                  child: Text("View All", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.deepOrange)),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: ListView(
                children: [
                  _transactionItem('Food', '-\$630.00', Colors.pink, Icons.fastfood),
                  _transactionItem('Entertainment', '-\$240.00', Colors.deepPurple, Icons.movie),
                  _transactionItem('Transport', '-\$500.00', Colors.orange, Icons.directions_car),
                  _transactionItem('Shopping', '-\$100.00', Colors.purple, Icons.shopping_bag),
                  _transactionItem('Fuel', '-\$250.00', Colors.grey, Icons.local_gas_station),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CenterFAB(onPressed: _onFabPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomBar(
        currentIndex: selectedIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: _onFabPressed,
      ),
    );
  }

  Widget _transactionItem(String label, String amount, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 24.r,
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text("Today", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
