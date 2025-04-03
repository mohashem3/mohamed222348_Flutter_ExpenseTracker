import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/upper_bar.dart';
import '../widgets/bottom_bar.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  double income = 0.0;
  double expense = 0.0;
  Map<String, double> expenseCategoryTotals = {};
  Map<String, double> incomeCategoryTotals = {};
  int selectedYear = DateTime.now().year;

  final Map<String, Color> categoryColors = {
    'Transport': Colors.deepOrange,
    'Food': Colors.pink,
    'Shopping': Colors.purple,
    'Entertainment': Colors.indigo,
    'Health': Colors.red,
    'Bills': Colors.brown,
    'Travel': Colors.teal,
    'Salary': Colors.green,
    'Freelance': Colors.blue,
    'Business': Colors.amber,
    'Investment': Colors.cyan,
    'Gift': Colors.orange,
    'Other': Colors.grey,
  };

  final _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/list');
        break;
    }
  }

  void _calculateTotals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .get();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    Map<String, double> expenseTotals = {};
    Map<String, double> incomeTotals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      double amount = (data['amount'] as num).toDouble();
      String type = data['type'];
      String category = data['category'];

      if (type == 'income') {
        totalIncome += amount;
        incomeTotals[category] = (incomeTotals[category] ?? 0) + amount;
      } else {
        totalExpense += amount;
        expenseTotals[category] = (expenseTotals[category] ?? 0) + amount;
      }
    }

    setState(() {
      income = totalIncome;
      expense = totalExpense;
      expenseCategoryTotals = expenseTotals;
      incomeCategoryTotals = incomeTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    double balance = income - expense;

    return Scaffold(
      appBar: const UpperBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard("Income", income, [Color(0xFF2E7D32), Color(0xFF81C784)]),
                _summaryCard("Balance", balance, [Color(0xFF2196F3), Color(0xFF9C27B0)]),
                _summaryCard("Expense", expense, [Color(0xFFC62828), Color(0xFFEF5350)]),
              ],
            ),
            SizedBox(height: 24.h),
            _buildPieChart("Top Spending Categories", expenseCategoryTotals),
            SizedBox(height: 24.h),
            _buildPieChart("Top Earning Categories", incomeCategoryTotals),
          ],
        ),
      ),
      floatingActionButton: CenterFAB(
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, List<Color> gradientColors) {
    return Container(
      width: 100.w,
      height: 80.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white)),
          SizedBox(height: 4.h),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, double> dataMap) {
    final total = dataMap.values.fold(0.0, (a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: dataMap.entries.map((entry) {
                  final percentage = (entry.value / total) * 100;
                  final color = categoryColors[entry.key] ?? Colors.grey;

                  return PieChartSectionData(
                    value: entry.value,
                    title: "${percentage.toStringAsFixed(1)}%",
                    color: color,
                    titleStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    radius: 70.r,
                  );
                }).toList(),
                centerSpaceRadius: 40.r,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: dataMap.entries.map((entry) {
              final color = categoryColors[entry.key] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  SizedBox(width: 6.w),
                  Text(entry.key, style: GoogleFonts.poppins(fontSize: 12.sp)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
