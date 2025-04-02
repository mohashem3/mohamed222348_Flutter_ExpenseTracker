import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/transaction_card.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/search_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/filter_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/view_transaction.dart';
import 'package:mohamed222348_expense_tracker/utils/category_icon.dart';


class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();

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

            _buildSwitch(),
            SizedBox(height: 16.h),

            // Live transaction stream
            Expanded(
              child: StreamBuilder<List<TransactionModel>>(
                stream: _transactionService.getTransactions(isExpense: _isExpense),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No transactions found."));
                  }

                  final transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionCard(
                        category: tx.category,
                        amount: tx.amount,
                        icon: getCategoryIcon(tx.category),
                        iconColor: getCategoryColor(tx.category),
                        isExpense: tx.isExpense,
                        onViewDetails: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewTransactionScreen(
                                amount: tx.amount,
                                category: tx.category,
                                note: tx.note,
                                date: tx.date,
                                isExpense: tx.isExpense,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
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
