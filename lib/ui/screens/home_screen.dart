// HomeScreen: Main dashboard screen of the app.
// - Displays welcome message with user info.
// - Shows a gradient card summarizing balance, income, and expenses.
// - Lists today’s transactions with view, edit, and delete options.
// - Integrates bottom navigation bar and FAB for screen switching and adding transactions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';
import 'package:mohamed222348_expense_tracker/services/auth_service.dart';
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/add_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/auth/login_screen.dart';
import 'package:mohamed222348_expense_tracker/ui/screens/view_transaction.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/transaction_card.dart';
import 'package:mohamed222348_expense_tracker/utils/category_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Holds the index of the currently selected tab in the bottom navigation bar.
  int selectedIndex = 0;

  // Stores the user's full name and their initials (used in avatar).
  String userName = '';
  String userInitials = '';

  // Holds total calculated values of the user's income, expense, and balance.
  double income = 0;
  double expense = 0;
  double balance = 0;

  // List to store only the transactions made today for display.
  List<TransactionModel> todayTransactions = [];

  @override
  void initState() {
    super.initState();
    // Load user name and initials from Firestore.
    _loadUserDetails();

    // Load income, expense, and balance totals from database.
    _loadTotals();

    // Load today's transactions from database to be displayed in list.
    _loadTodayTransactions();
  }

 // 🔹 Retrieves the current user's display name from Firestore
// and extracts their initials for display in the UI.
Future<void> _loadUserDetails() async {
  final user = FirebaseAuth.instance.currentUser; // Get the currently logged-in Firebase user

  if (user != null) {
    // Fetch the document associated with this user from the 'users' collection in Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    // Extract the name field from the document, or use "User" as a fallback
    final name = doc['name'] ?? 'User';

    // Use helper method to get initials from the name
    final initials = _getInitials(name);

    // Update the UI with the fetched name and generated initials
    setState(() {
      userName = name;
      userInitials = initials;
    });
  }
}

// 🔹 Helper function that returns initials from a given full name
// Examples: "John Smith" => "JS", "Ayman" => "A"
String _getInitials(String name) {
  final parts = name.trim().split(' '); // Split the name into parts by spaces
  if (parts.length == 1) {
    // If the name is a single word (e.g., "Ayman"), return first letter capitalized
    return parts[0].substring(0, 1).toUpperCase();
  }

  // If the name has two or more words, return the first letter of the first and second words
  return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
}

// 🔹 Calculates total income and total expense for the current user,
// then computes the balance as income - expense
Future<void> _loadTotals() async {
  // Call the service method that sums all income and expense transactions
  final totals = await TransactionService().calculateTotals();

  // Update the UI state with the new calculated values
  setState(() {
    income = totals['income'] ?? 0;
    expense = totals['expense'] ?? 0;
    balance = income - expense;
  });
}

// 🔹 Loads only the transactions created today (based on date match)
Future<void> _loadTodayTransactions() async {
  final user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
  if (user == null) return; // Exit early if no user is logged in

  final now = DateTime.now(); // Get the current date and time

  // Fetch all transactions for the user using the service layer
  final all = await TransactionService().getAllTransactions();

  // Filter transactions to keep only those that match today's date
  setState(() {
    todayTransactions = all.where((tx) =>
      tx.date.year == now.year &&
      tx.date.month == now.month &&
      tx.date.day == now.day
    ).toList();
  });
}


  // Handles bottom navigation tab switching.
// Navigates to different named routes based on selected index.
void _onTabSelected(int index) {
  // Update the state to reflect the selected tab index (used for icon highlighting)
  setState(() => selectedIndex = index);

  // Navigate to the appropriate screen based on the selected tab
  if (index == 3) {
    // Navigate to the transaction list screen
    Navigator.pushReplacementNamed(context, '/list');
  } else if (index == 2) {
    // Navigate to the profile screen
    Navigator.pushReplacementNamed(context, '/profile');
  } else if (index == 1) {
    // Navigate to the stats screen
    Navigator.pushReplacementNamed(context, '/stats');
  }
  // If index == 0 (Home), no navigation is triggered because we're already on Home
}

// Handles press of the floating action button to add a new transaction.
// After user returns, updates both the transaction list and balance totals.
void _onFabPressed() async {
  // Open the AddTransactionScreen and wait for the result
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
  );

  // If the user added or updated a transaction, reload today's transactions and totals
  if (result == 'updated' || result == 'added') {
    await _loadTodayTransactions(); // Refresh today's transactions
    await _loadTotals(); // Refresh income, expense, and balance
  }
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Top app bar shared across all screens (custom reusable component)
    appBar: const UpperBar(),

    // Main body content with padding for layout breathing space
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔶 User Welcome Header with Avatar and Logout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 🔸 Circle avatar showing user initials in orange background
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      userInitials,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // 🔸 Welcome text and full name under avatar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                      Text(
                        userName.isNotEmpty ? userName : 'User',
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              // 🔸 Logout icon button → Logs out and navigates to login screen
              IconButton(
                onPressed: () async {
                  final navigator = Navigator.of(context); // Prevent async Navigator warning
                  await AuthService().logout(); // Call logout method from AuthService
                  navigator.pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); // Go to login
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.deepOrange),
              )
            ],
          ),

          SizedBox(height: 20.h),

          // 🔶 Gradient Summary Card: Balance, Income, and Expense
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFF57C00)], // Gold → Orange
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // 🔸 Label for total balance
                Text("Total Balance", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.sp)),

                SizedBox(height: 4.h),

                // 🔸 Total balance value
                Text(
                  "\$${balance.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 16.h),

                // 🔸 Income and Expense breakdown row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 Income info (down arrow + green)
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "\$${income.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // 🔹 Expense info (up arrow + red)
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "\$${expense.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 🔶 Header Row: "Latest Transactions" + View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Transactions",
                style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/list'),
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.deepOrange),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 🔶 Scrollable list of today’s transactions OR placeholder text
          Expanded(
            child: todayTransactions.isEmpty
                ? const Center(child: Text("No transactions today."))
                : ListView.builder(
                    itemCount: todayTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = todayTransactions[index];
                      final icon = getCategoryIcon(tx.category);
                      final color = getCategoryColor(tx.category).withAlpha((0.7 * 255).toInt()); // 🔸 Soft icon color

                      return TransactionCard(
                        category: tx.category,
                        amount: tx.amount,
                        icon: icon,
                        iconColor: color,
                        isExpense: tx.isExpense,
                        dateTime: tx.date,

                        // 🔸 View full transaction details screen
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

                        // 🔸 Edit transaction screen (reuses AddTransactionScreen)
                        onEdit: () async {
                          final result = await Navigator.pushNamed(context, '/add', arguments: tx);
                          if (result == 'updated') {
                            await _loadTodayTransactions();
                            await _loadTotals();
                          }
                        },

                        // 🔸 Delete transaction with confirmation dialog
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
                            await TransactionService().deleteTransaction(tx.id);
                            await _loadTodayTransactions();
                            await _loadTotals();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ),

    // 🔶 Floating Action Button to add a new transaction
    floatingActionButton: CenterFAB(onPressed: _onFabPressed),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    // 🔶 Bottom Navigation Bar to switch between screens
    bottomNavigationBar: BottomBar(
      currentIndex: selectedIndex,
      onTabSelected: _onTabSelected,
      onFabPressed: _onFabPressed,
    ),
  );
}
}