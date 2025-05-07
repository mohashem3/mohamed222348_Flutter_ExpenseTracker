// transaction_list.dart

// Flutter core UI toolkit
import 'package:flutter/material.dart';
// Provides responsive sizing like 12.w or 16.h
import 'package:flutter_screenutil/flutter_screenutil.dart';
// For date formatting like 'dd MMM yyyy'
import 'package:intl/intl.dart';

// App-specific model class representing a transaction
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';
// Service layer to interact with Firestore and manage transaction CRUD operations
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';

// Custom app bars and bottom navigation
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';

// Reusable widget that visually displays a transaction as a card
import 'package:mohamed222348_expense_tracker/ui/widgets/transaction_card.dart';
// Custom search input widget for filtering transactions by keyword
import 'package:mohamed222348_expense_tracker/ui/widgets/search_transaction.dart';
// Dropdown widget for applying transaction filters (e.g. date, amount)
import 'package:mohamed222348_expense_tracker/ui/widgets/filter_transaction.dart';
// Screen for viewing full transaction details in read-only mode
import 'package:mohamed222348_expense_tracker/ui/screens/view_transaction.dart';
// Utility for mapping transaction categories to icons and colors
import 'package:mohamed222348_expense_tracker/utils/category_icon.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key}); // Constructor for the screen widget

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState(); // Creates the mutable state
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService(); 
  // Service instance to fetch and delete transactions from backend

  String _searchQuery = '';          // Holds current search input
  String _selectedFilter = 'Newest'; // Default sorting/filtering selection
  bool _isExpense = true;            // True means show expenses, false means show income
  int selectedIndex = 3;             // Default selected index in bottom navigation bar (3 = list)

  List<TransactionModel> _transactions = []; // Holds fetched transactions from Firestore
  bool _isFirstLoad = true;                  // True while data is being fetched for the first time
  DateTime? _selectedDate;                   // Optional filter for a specific day

  @override
  void initState() {
    super.initState();       // Calls the parent initState lifecycle method
    _fetchTransactions();    // Begin loading transaction data when screen starts
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _transactions = [];    // Clear any previously loaded data
      _isFirstLoad = true;   // Show loading state
    });

    // Retrieve transactions (either expenses or income depending on _isExpense flag)
    final result = await _transactionService.getAllTransactions(isExpense: _isExpense);

    setState(() {
      _transactions = result;   // Populate list with fetched data
      _isFirstLoad = false;     // Stop loading indicator
    });
  }


  // This computed property returns the filtered and sorted list of transactions
List<TransactionModel> get _filteredTransactions {
  // Start by copying all transactions into a new list
  List<TransactionModel> filtered = [..._transactions];

  // Step 1: Apply search filter if search query is not empty
  if (_searchQuery.isNotEmpty) {
    final query = _searchQuery.toLowerCase(); // Convert search query to lowercase for case-insensitive matching
    filtered = filtered.where((tx) =>
      tx.category.toLowerCase().contains(query) || // Match category name
      tx.note.toLowerCase().contains(query) ||     // Match transaction note
      tx.amount.toString().contains(query)         // Match amount as a string
    ).toList();
  }

  // Step 2: If a specific date is selected, filter transactions that match that day
  if (_selectedDate != null) {
    filtered = filtered.where((tx) =>
      tx.date.year == _selectedDate!.year &&
      tx.date.month == _selectedDate!.month &&
      tx.date.day == _selectedDate!.day
    ).toList();
  } else {
    // Step 3: Apply filter based on selected dropdown option (only if no specific date is selected)
    switch (_selectedFilter) {
      case 'Oldest':
        // Sort transactions by date ascending (oldest first)
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;

      case 'Amount ↑':
        // Sort by amount descending (largest amount first)
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;

      case 'Amount ↓':
        // Sort by amount ascending (smallest amount first)
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;

      case 'Category A-Z':
        // Sort alphabetically by category name
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;

      case 'This Month':
        // Filter transactions from the current month
        final now = DateTime.now();
        filtered = filtered.where((tx) =>
          tx.date.month == now.month && tx.date.year == now.year
        ).toList();
        break;

      case 'This Year':
        // Filter transactions from the current year
        final now = DateTime.now();
        filtered = filtered.where((tx) => tx.date.year == now.year).toList();
        break;

      case 'Last 7 Days':
        // Filter transactions from the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered.where((tx) => tx.date.isAfter(weekAgo)).toList();
        break;

      default:
        // Default sort by date descending (newest first)
        filtered.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  // Return the final filtered and sorted list
  return filtered;
}

// This computed property calculates the total amount of currently visible transactions
double get _totalAmount {
  // Sum all amounts in the filtered transaction list
  return _filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
}

  // This method handles bottom navigation bar tab changes
void _onTabSelected(int index) {
  // Update the selected tab index in the state
  setState(() => selectedIndex = index);

  // Navigate to the corresponding screen based on tab index
  if (index == 0) {
    // Navigate to the Home screen
    Navigator.pushReplacementNamed(context, '/home');
  } else if (index == 2) {
    // Navigate to the Profile screen
    Navigator.pushReplacementNamed(context, '/profile');
  }
  else if (index == 1) {
    // Navigate to the Stats screen
    Navigator.pushReplacementNamed(context, '/stats');
  }
  else if (index == 3) {
    // Navigate to the Transaction List screen (this screen)
    Navigator.pushReplacementNamed(context, '/list');
  }
}

// This method is called when the floating action button (FAB) is pressed
void _onFabPressed() {
  // Navigate to the Add Transaction screen
  Navigator.pushNamed(context, '/add');
}

// This method opens a date picker and sets _selectedDate when a date is picked
Future<void> _selectDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,                       // Current build context
    initialDate: _selectedDate ?? DateTime.now(), // Start with currently selected date or today
    firstDate: DateTime(2020),              // Earliest selectable date
    lastDate: DateTime.now(),              // Latest date is today
  );

  // If the user picked a date, update state with the selected date
  if (picked != null) {
    setState(() {
      _selectedDate = picked;              // Store the picked date
      _selectedFilter = 'Newest';          // Reset filter to default to avoid conflict with date
    });
  }
}


 // Builds a horizontal switch UI to toggle between viewing Income or Expense transactions
Widget _buildSwitch() {
  return Container(
    height: 44.h, // Responsive height using ScreenUtil
    margin: EdgeInsets.only(top: 16.h), // Top spacing
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40.r), // Rounded edges for pill-like appearance
      border: Border.all(
        // Orange border with reduced opacity
        color: const Color(0xFFF57C00).withAlpha((0.4 * 255).toInt()),
        width: 1,
      ),
    ),
    // The switch consists of two tabs inside a Row: Income and Expenses
    child: Row(
      children: [
        _switchTab("Income", !_isExpense),   // Highlight when _isExpense is false
        _switchTab("Expenses", _isExpense),  // Highlight when _isExpense is true
      ],
    ),
  );
}

// Builds each individual switch tab (Income or Expenses)
Widget _switchTab(String label, bool isActive) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        // When a tab is tapped, update _isExpense based on selected label
        setState(() => _isExpense = label == "Expenses");
        _fetchTransactions(); // Refresh transaction list for selected type
      },
      child: Container(
        height: double.infinity,
        decoration: isActive
            ? BoxDecoration(
                // Highlight active tab with a gradient background
                borderRadius: BorderRadius.circular(40.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange gradient
                ),
              )
            : null, // No background decoration if inactive
        child: Center(
          child: Text(
            label, // Label text: "Income" or "Expenses"
            style: TextStyle(
              fontWeight: FontWeight.w600, // Semi-bold font
              fontSize: 13.sp,             // Responsive font size
              color: isActive ? Colors.white : Colors.grey, // White for active, grey for inactive
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
    // Top app bar using your custom reusable component
    appBar: const UpperBar(),

    // Body content of the screen wrapped in padding
    body: Padding(
      padding: EdgeInsets.all(20.w), // Responsive padding using ScreenUtil
      child: Column(
        children: [
          // First row contains the search bar and filter dropdown
          Row(
            children: [
              // Search bar takes 3 parts of the row space
              Expanded(
                flex: 3,
                child: SearchTransaction(
                  // Callback updates _searchQuery on every input change
                  onSearch: (query) => setState(() => _searchQuery = query),
                ),
              ),
              SizedBox(width: 12.w), // Horizontal spacing between search and filter
              // Dropdown filter component for sorting and filtering logic
              FilterTransaction(
                selectedFilter: _selectedFilter, // Currently selected filter label
                onFilterChanged: (newFilter) {
                  // Update filter and reset date filter when user selects a new one
                  setState(() {
                    _selectedFilter = newFilter;
                    _selectedDate = null;
                  });
                },
              ),
            ],
          ),

          // Toggle switch for Income / Expenses
          _buildSwitch(),

          SizedBox(height: 12.h), // Spacing below the switch

          // Date picker box that opens a calendar when tapped
          GestureDetector(
            onTap: () => _selectDate(context), // Opens the date picker dialog
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w), // Internal spacing
              margin: EdgeInsets.only(bottom: 14.h), // Spacing below date selector
              decoration: BoxDecoration(
                color: Colors.orange.shade50, // Light orange background
                borderRadius: BorderRadius.circular(12.r), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Text on left, icon on right
                children: [
                  Text(
                    _selectedDate != null
                        // If a date is selected, format it
                        ? DateFormat('EEE, d MMMM y').format(_selectedDate!)
                        // Otherwise show default text
                        : 'All Dates',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.orange), // Calendar icon
                ],
              ),
            ),
          ),


           // Premium-style Total Badge
Container(
  width: 180.w, // Responsive fixed width using ScreenUtil
  height: 80.h, // Responsive fixed height
  margin: EdgeInsets.only(bottom: 16.h), // Space below the badge
  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w), // Internal spacing
  decoration: BoxDecoration(
    // Background color changes based on whether user is viewing expenses or income
    color: _isExpense ? Colors.red.shade50 : Colors.green.shade50,
    borderRadius: BorderRadius.circular(22.r), // Rounded container corners
    border: Border.all(
      // Border color matches the type (faint red or green with reduced opacity)
      color: (_isExpense ? Colors.red.shade200 : Colors.green.shade200)
          .withAlpha((0.4 * 255).toInt()),
    ),
    boxShadow: [
      // Subtle shadow effect that also depends on the type (income or expense)
      BoxShadow(
        color: (_isExpense ? Colors.red : Colors.green)
            .withAlpha((0.2 * 255).toInt()),
        blurRadius: 12, // How soft the shadow is
        offset: const Offset(0, 6), // Shadow position
      )
    ],
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
    children: [
      Text(
        // Label text depends on view type
        _isExpense ? "Total Expenses" : "Total Income",
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700, // Neutral label color
        ),
      ),
      SizedBox(height: 4.h), // Small vertical gap
      Text(
        // Display total amount for filtered transactions with two decimals
        "\$${_totalAmount.toStringAsFixed(2)}",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: _isExpense ? Colors.red : Colors.green, // Highlighted color
        ),
      ),
    ],
  ),
),

// Transaction List
// The list of transactions is conditionally rendered
Expanded(
  child: _isFirstLoad
      ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
      : _filteredTransactions.isEmpty
          ? const Center(child: Text("No transactions found.")) // Empty message if no results
          : ListView.builder(
              // Build a scrollable list of transaction cards
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = _filteredTransactions[index]; // Get transaction at current index

                return TransactionCard(
                  category: tx.category,
                  amount: tx.amount,
                  icon: getCategoryIcon(tx.category), // Select icon based on category
                  iconColor: getCategoryColor(tx.category), // Match icon color to category
                  isExpense: tx.isExpense,
                  dateTime: tx.date,
                  
                  // Callback to edit transaction
                  onEdit: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/add',
                      arguments: tx, // Pass current transaction for editing
                    );

  // If we get a result like 'updated', refresh list
if (result == 'updated') {
  await _fetchTransactions(); // Reload transactions to reflect updated changes
}
},

// Handle deletion logic
onDelete: () async {
  // Show confirmation dialog before deleting
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Confirm Deletion"), // Title of the dialog
      content: const Text("Are you sure you want to delete this transaction?"), // Message
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false), // User cancelled
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true), // User confirmed deletion
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Red delete button
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  // If user confirms, proceed to delete the transaction
  if (confirm == true) {
    await _transactionService.deleteTransaction(tx.id); // Delete by ID
    await _fetchTransactions(); // Refresh list after deletion
  }
},

// Handle "view details" button logic
onViewDetails: () {
  // Navigate to a dedicated screen to view transaction details
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ViewTransactionScreen(
        amount: tx.amount,         // Pass transaction amount
        category: tx.category,     // Pass category
        note: tx.note,             // Pass note
        date: tx.date,             // Pass date
        isExpense: tx.isExpense,   // Pass transaction type
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
floatingActionButton: CenterFAB(onPressed: _onFabPressed), // Floating action button to add a transaction
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Place FAB at center bottom
bottomNavigationBar: BottomBar(
  currentIndex: selectedIndex,          // Highlight current tab
  onTabSelected: _onTabSelected,        // Handle tab change
  onFabPressed: _onFabPressed,          // Handle FAB press
),
);
}
}
