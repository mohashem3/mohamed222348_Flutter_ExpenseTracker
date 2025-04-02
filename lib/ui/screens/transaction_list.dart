// transaction_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

  List<TransactionModel> _transactions = [];
  bool _isFirstLoad = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _transactions = [];
      _isFirstLoad = true;
    });

    final result = await _transactionService.getAllTransactions(isExpense: _isExpense);
    setState(() {
      _transactions = result;
      _isFirstLoad = false;
    });
  }

  List<TransactionModel> get _filteredTransactions {
    List<TransactionModel> filtered = [..._transactions];

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((tx) =>
          tx.category.toLowerCase().contains(query) ||
          tx.note.toLowerCase().contains(query) ||
          tx.amount.toString().contains(query)).toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((tx) =>
          tx.date.year == _selectedDate!.year &&
          tx.date.month == _selectedDate!.month &&
          tx.date.day == _selectedDate!.day).toList();
    } else {
      switch (_selectedFilter) {
        case 'Oldest':
          filtered.sort((a, b) => a.date.compareTo(b.date));
          break;
        case 'Amount ↑':
          filtered.sort((a, b) => b.amount.compareTo(a.amount)); // Highest first
          break;
        case 'Amount ↓':
          filtered.sort((a, b) => a.amount.compareTo(b.amount)); // Lowest first
          break;
        case 'Category A-Z':
          filtered.sort((a, b) => a.category.compareTo(b.category));
          break;
        case 'This Month':
          final now = DateTime.now();
          filtered = filtered.where((tx) =>
              tx.date.month == now.month && tx.date.year == now.year).toList();
          break;
        case 'This Year':
          final now = DateTime.now();
          filtered = filtered.where((tx) => tx.date.year == now.year).toList();
          break;
        case 'Last 7 Days':
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          filtered = filtered.where((tx) => tx.date.isAfter(weekAgo)).toList();
          break;
        default:
          filtered.sort((a, b) => b.date.compareTo(a.date)); // Newest
      }
    }

    return filtered;
  }

  double get _totalAmount {
    return _filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedFilter = 'Newest';
      });
    }
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
        onTap: () {
          setState(() => _isExpense = label == "Expenses");
          _fetchTransactions();
        },
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
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SearchTransaction(
                    onSearch: (query) => setState(() => _searchQuery = query),
                  ),
                ),
                SizedBox(width: 12.w),
                FilterTransaction(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (newFilter) {
                    setState(() {
                      _selectedFilter = newFilter;
                      _selectedDate = null;
                    });
                  },
                ),
              ],
            ),
            _buildSwitch(),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEE, d MMMM y').format(_selectedDate!)
                          : 'All Dates',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.orange),
                  ],
                ),
              ),
            ),

            // 🔥 Premium-style Total Badge
            Container(
              width: 180.w,
              height: 80.h,
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: _isExpense ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: (_isExpense ? Colors.red.shade200 : Colors.green.shade200).withOpacity(0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isExpense ? Colors.red : Colors.green).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpense ? "Total Expenses" : "Total Income",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "\$${_totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: _isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction List
            // Inside the ListView.builder block:
Expanded(
  child: _isFirstLoad
      ? const Center(child: CircularProgressIndicator())
      : _filteredTransactions.isEmpty
          ? const Center(child: Text("No transactions found."))
          : ListView.builder(
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = _filteredTransactions[index];
                return TransactionCard(
                  category: tx.category,
                  amount: tx.amount,
                  icon: getCategoryIcon(tx.category),
                  iconColor: getCategoryColor(tx.category),
                  isExpense: tx.isExpense,
                  dateTime: tx.date,
                  onEdit: () async {
  final result = await Navigator.pushNamed(
    context,
    '/add',
    arguments: tx,
  );

  // If we get a result like 'updated', refresh list
  if (result == 'updated') {
    await _fetchTransactions();
  }
},

                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text("Are you sure you want to delete this transaction?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Delete", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _transactionService.deleteTransaction(tx.id);
                      await _fetchTransactions(); // Refresh list
                    }
                  },
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
            ),
)

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
