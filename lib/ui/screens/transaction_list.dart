import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/transaction_card.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/search_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/filter_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/view_transaction.dart';


class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Newest';
  bool _isExpense = true;

  int selectedIndex = 3;

  void _onTabSelected(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _onFabPressed() {
    Navigator.pushNamed(context, '/add');
  }

  Widget _buildSwitch() {
    return Container(
      height: 44.h,
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: const Color(0xFFF57C00).withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          _switchTab("Income", !_isExpense),
          _switchTab("Expenses", _isExpense),
        ],
      ),
    );
  }

  Widget _switchTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isExpense = label == "Expenses"),
        child: Container(
          height: double.infinity,
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(40.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                  ),
                )
              : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UpperBar(),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Filter Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SearchTransaction(
                    onSearch: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                FilterTransaction(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (newFilter) {
                    setState(() {
                      _selectedFilter = newFilter;
                    });
                  },
                ),
              ],
            ),

            // Switch (Income/Expenses)
            _buildSwitch(),

            SizedBox(height: 16.h),
            // Date + Total badge
Padding(
  padding: EdgeInsets.only(bottom: 12.h),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Sat, 20 March 2021",
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
      Container(
        width: 120.w,
        height: 28.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          "-\$500.00",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: Colors.red,
          ),
        ),
      ),
    ],
  ),
),

            // List of Transactions
            Expanded(
              child: ListView(
                children: [
                  TransactionCard(
  category: "Home Rent",
  amount: -350.0,
  icon: Icons.home,
  iconColor: Colors.orange,
  onViewDetails: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewTransactionScreen(
          amount: -350.0,
          category: "Home Rent",
          note: "Monthly payment",
          date: DateTime(2021, 3, 20),
          isExpense: true,
        ),
      ),
    );
  },
),

                  TransactionCard(
                    category: "Pet Groom",
                    amount: -50.0,
                    icon: Icons.pets,
                    iconColor: Colors.blue,
                  ),
                  TransactionCard(
                    category: "Recharge",
                    amount: -100.0,
                    icon: Icons.phone_android,
                    iconColor: Colors.teal,
                  ),
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
}
