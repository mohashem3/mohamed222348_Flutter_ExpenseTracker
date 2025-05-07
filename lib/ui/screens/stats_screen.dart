// Import required packages and libraries:
// - Firestore and FirebaseAuth: for fetching and authenticating user data
// - fl_chart: used for rendering pie charts
// - screenutil and google_fonts: for responsive sizing and custom fonts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/upper_bar.dart';
import '../widgets/bottom_bar.dart';

// StatsScreen is a stateful widget responsible for displaying income, expense,
// balance summary, and category-wise analytics using charts.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Firebase instances to access authentication and Firestore database
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Variables to hold overall income, expense, and category-wise totals
  double income = 0.0;
  double expense = 0.0;
  Map<String, double> expenseCategoryTotals = {}; // e.g., {Food: 250, Travel: 120}
  Map<String, double> incomeCategoryTotals = {};  // e.g., {Salary: 1500, Freelance: 400}
  int selectedYear = DateTime.now().year; // Currently selected year (for potential future filtering)

  // Predefined color map for each category used in the pie chart visuals
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

  // Index of the currently selected tab in the bottom navigation bar
  final _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _calculateTotals(); // Trigger the initial calculation of all stats from Firestore
  }

  // Handles navigation when a tab in the bottom bar is tapped
  void _onTabSelected(int index) {
    if (index == _currentIndex) return; // Prevent navigation if already on this tab
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break; // Already on stats page, do nothing
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/list');
        break;
    }
  }

  // Fetches all transactions from Firestore and calculates:
  // - total income and expense
  // - income totals per category
  // - expense totals per category
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
      double amount = (data['amount'] as num).toDouble(); // Convert numeric value to double
      String type = data['type'];                          // Either 'income' or 'expense'
      String category = data['category'];                  // Category label

      // Accumulate totals based on transaction type
      if (type == 'income') {
        totalIncome += amount;
        incomeTotals[category] = (incomeTotals[category] ?? 0) + amount;
      } else {
        totalExpense += amount;
        expenseTotals[category] = (expenseTotals[category] ?? 0) + amount;
      }
    }

    // Update state with the calculated values to re-render the UI
    setState(() {
      income = totalIncome;
      expense = totalExpense;
      expenseCategoryTotals = expenseTotals;
      incomeCategoryTotals = incomeTotals;
    });
  }


  @override
Widget build(BuildContext context) {
  // Compute the current balance by subtracting total expenses from total income
  double balance = income - expense;

  return Scaffold(
    appBar: const UpperBar(), // Custom reusable app bar widget

    // The main body of the screen is scrollable to accommodate pie charts and summary cards on smaller screens
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.w), // Responsive padding using screenutil
      child: Column(
        children: [
          // Row containing three summary cards: Income, Balance, Expense
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryCard("Income", income, [Color(0xFF2E7D32), Color(0xFF81C784)]),
              _summaryCard("Balance", balance, [Color(0xFF2196F3), Color(0xFF9C27B0)]),
              _summaryCard("Expense", expense, [Color(0xFFC62828), Color(0xFFEF5350)]),
            ],
          ),

          SizedBox(height: 24.h), // Spacing between summary and pie chart

          // Pie chart for top expense categories
          _buildPieChart("Top Spending Categories", expenseCategoryTotals),

          SizedBox(height: 24.h),

          // Pie chart for top income categories
          _buildPieChart("Top Earning Categories", incomeCategoryTotals),
        ],
      ),
    ),

    // Floating Action Button to add a new transaction
    floatingActionButton: CenterFAB(
      onPressed: () => Navigator.pushNamed(context, '/add'),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    // Reusable bottom navigation bar with current tab index set to stats
    bottomNavigationBar: BottomBar(
      currentIndex: _currentIndex,
      onTabSelected: _onTabSelected,
      onFabPressed: () => Navigator.pushNamed(context, '/add'),
    ),
  );
}

// Reusable widget to render a compact card showing a single metric (Income, Balance, or Expense)
Widget _summaryCard(String title, double amount, List<Color> gradientColors) {
  return Container(
    width: 100.w,       // Responsive width
    height: 80.h,       // Responsive height
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      // Gradient background for visual appeal
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
          offset: Offset(0, 3), // Slight shadow for elevation effect
        )
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Metric label (e.g., "Income")
        Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white)),

        SizedBox(height: 4.h),

        // Dollar amount value formatted to 2 decimal places
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Prevents overflow in case of long values
        ),
      ],
    ),
  );
}


  // Builds a styled pie chart widget with category-wise distribution of expenses or income
Widget _buildPieChart(String title, Map<String, double> dataMap) {
  // Calculate total amount to determine relative percentages for each category
  final total = dataMap.values.fold(0.0, (a, b) => a + b);

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w), // Responsive padding
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4), // Slight elevation for card effect
        )
      ],
    ),
    child: Column(
      children: [
        // Title of the chart (e.g., "Top Spending Categories")
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 12.h),

        // Container for the pie chart visualization using FLChart library
        AspectRatio(
          aspectRatio: 1.3, // Makes chart more elliptical than circular for aesthetic balance
          child: PieChart(
            PieChartData(
              sections: dataMap.entries.map((entry) {
                // Compute each section's percentage
                final percentage = (entry.value / total) * 100;
                // Use predefined color or default grey
                final color = categoryColors[entry.key] ?? Colors.grey;

                return PieChartSectionData(
                  value: entry.value, // Actual value represented by the slice
                  title: "${percentage.toStringAsFixed(1)}%", // Display percentage in the slice
                  color: color,
                  titleStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  radius: 70.r, // Size of each slice
                );
              }).toList(),

              centerSpaceRadius: 40.r, // Creates a hole in the center (doughnut style)
              sectionsSpace: 2,        // Space between slices
              borderData: FlBorderData(show: false), // No border around the chart
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Legend for the chart (colored dot + category name)
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: dataMap.entries.map((entry) {
            final color = categoryColors[entry.key] ?? Colors.grey;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Colored circle representing category
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                // Category label
                Text(
                  entry.key,
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    ),
  );
}
}