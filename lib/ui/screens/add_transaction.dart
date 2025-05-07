// Core Flutter UI toolkit
import 'package:flutter/material.dart';

// Used for responsive sizing: .h, .w, .sp (ScreenUtil extension)
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Allows using Google Fonts like Poppins, Montserrat, etc.
import 'package:google_fonts/google_fonts.dart';

// Used to format DateTime (e.g., yyyy-MM-dd)
import 'package:intl/intl.dart';

// Data model representing a single transaction (amount, note, category, etc.)
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';

// Service that handles Firestore operations (add, update, delete transactions)
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';

// Custom widget that renders the AppBar with consistent styling across screens
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';

// This screen handles both creating a new transaction and editing an existing one
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // Optional: if not null, the user is editing an existing transaction

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState(); // Returns the mutable state object
}

// The state class manages user input, UI state (loading, toggles), and logic
class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Tracks whether the transaction is an expense (default = true). If false, it's income
  bool isExpense = true;

  // Stores the currently selected category name (default = "Transport")
  String selectedCategory = 'Transport';

  // Controller to read/write the amount input field (default = '0')
  final amountController = TextEditingController(text: '0');

  // Controller to read/write the note input field
  final noteController = TextEditingController();

  // Controller for user-defined custom category (only used when "Custom Category" is selected)
  final customCategoryController = TextEditingController();

  // Holds the currently selected date for the transaction (default = today)
  DateTime selectedDate = DateTime.now();

  // Controls whether the Save button is disabled (while saving = true)
  bool isSaving = false;

  // Fixed list of available expense categories
  final List<String> expenseCategories = [
    'Transport', 'Food', 'Shopping', 'Entertainment', 'Health', 'Bills', 'Travel', 'Custom Category',
  ];

  // Fixed list of available income categories
  final List<String> incomeCategories = [
    'Salary', 'Freelance', 'Business', 'Investment', 'Gift', 'Other', 'Custom Category',
  ];

  // Called once when this screen is first created — used to pre-fill fields when editing
  @override
  void initState() {
    super.initState();

    // Check if the screen was opened to edit an existing transaction
    final tx = widget.transaction;
    if (tx != null) {
      isExpense = tx.isExpense; // Set correct type (income/expense)
      
      // Try to match the saved category; if it's not in the standard list, fallback to custom input
      selectedCategory = incomeCategories.contains(tx.category) || expenseCategories.contains(tx.category)
          ? tx.category
          : 'Custom Category';

      // Pre-fill the custom category field if needed
      if (selectedCategory == 'Custom Category') {
        customCategoryController.text = tx.category;
      }

      // Pre-fill amount, note, and date
      amountController.text = tx.amount.toString();
      noteController.text = tx.note;
      selectedDate = tx.date;
    }
  }

  // Opens a date picker and updates the selectedDate if user selects a new one
  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Prevents picking dates too far in the past
      lastDate: DateTime.now(),  // Prevents picking future dates
    );
    if (picked != null) setState(() => selectedDate = picked); // Update state if a new date is chosen
  }

  // Handles form validation and saves a new or edited transaction
  Future<void> saveTransaction() async {
    // Clean and validate amount field
    final amountText = amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      showMessage('Enter a valid amount');
      return;
    }

    // Handle category name based on user selection (custom or fixed)
    String category = selectedCategory == 'Custom Category'
        ? customCategoryController.text.trim()
        : selectedCategory;

    // Validate category
    if (category.isEmpty) {
      showMessage('Category cannot be empty');
      return;
    }

    // Set loading state to show spinner and disable save button
    setState(() => isSaving = true);

    // Access our Firestore logic from the service class
    final service = TransactionService();
    final transaction = widget.transaction;

    if (transaction != null) {
      // Editing an existing transaction
      await service.updateTransaction(
        id: transaction.id,
        amount: double.parse(amountText),
        category: category,
        note: noteController.text.trim(),
        date: selectedDate,
        isExpense: isExpense,
      );
    } else {
      // Creating a new transaction
      await service.addTransaction(
        amount: double.parse(amountText),
        category: category,
        note: noteController.text.trim(),
        date: selectedDate,
        isExpense: isExpense,
      );
    }

    // Show confirmation to user
    showMessage('Transaction saved!', isSuccess: true);

    // Wait a short time before navigating back (so user sees the message)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return; // Make sure widget still exists

    // Close screen and send result back to previous screen (e.g., to trigger a refresh)
    if (context.mounted) Navigator.pop(context, 'updated');
  }

  // Shows a floating snackbar with a message (success or error)
  void showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent, // Green for success, red for errors
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Returns the base color used in gradients and borders (orange)
  Color _gradientColor() => const Color(0xFFF57C00);


  @override
// This is the build method that defines the UI of the screen.
// It gets called every time setState() is triggered.
Widget build(BuildContext context) {
  // Determine which category list to use based on transaction type
  final categories = isExpense ? expenseCategories : incomeCategories;

  return Scaffold(
    // Custom AppBar imported from reusable component (with title, back button, etc.)
    appBar: const UpperBar(),

    // Padding wraps the entire body content to provide spacing from screen edges
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w), // Responsive horizontal padding

      // Center ensures that everything is centered vertically and horizontally
      child: Center(
        // Makes entire screen scrollable (important for small screens/keyboards)
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 18.h),

          // All form elements are placed vertically using Column
          child: Column(
            children: [
              // Expense/Income switch toggle UI
              _buildSwitch(),

              SizedBox(height: 24.h), // Spacer between widgets

              // Input field for the amount ($), with gradient text style
              _buildAmount(),

              SizedBox(height: 24.h),

              // Show either a dropdown OR a custom input field based on category selection
              selectedCategory == 'Custom Category'
                  ? _inputField(
                      icon: Icons.edit, // Pencil icon for custom category
                      child: TextField(
                        controller: customCategoryController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Enter category name', // Placeholder text
                          hintStyle: GoogleFonts.poppins(),
                        ),
                      ),
                    )
                  : _inputField(
                      // Get matching icon for the selected category using helper method
                      icon: getCategoryIcon(selectedCategory),
                      iconSize: 18.sp,
                      child: DropdownButtonHideUnderline( // Hides default underline
                        child: DropdownButton<String>(
                          value: selectedCategory, // Current selected value
                          isExpanded: true, // Makes dropdown fill available width
                          icon: const Icon(Icons.arrow_drop_down), // Dropdown arrow

                          // Handle selection changes
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },

                          // Generate dropdown options from category list
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: GoogleFonts.poppins()),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

              SizedBox(height: 16.h),

              // Note input field with edit_note icon
              _inputField(
                icon: Icons.edit_note,
                child: TextField(
                  controller: noteController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Note', // Optional note from user
                    hintStyle: GoogleFonts.poppins(),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Date picker field, opens a calendar on tap
              _inputField(
                icon: Icons.calendar_today, // Calendar icon
                child: GestureDetector(
                  onTap: pickDate, // Triggers date picker dialog
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate), // Formats date
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // Save button (either adds new or updates existing transaction)
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    ),
  );
}

  // This widget builds a single tab for the income/expense switch UI
// `label` is either "Income" or "Expenses"
// `isActive` determines which tab is selected (highlighted)
Widget _switchTab(String label, bool isActive) {
  return Expanded( // Takes equal horizontal space within the Row
    child: GestureDetector(
      // When tapped, it sets the mode and resets the default category
      onTap: () => setState(() {
        isExpense = label == "Expenses"; // Set boolean based on label
        selectedCategory = isExpense ? "Transport" : "Salary"; // Set default category
      }),
      child: Container(
        height: double.infinity,
        // If this tab is active, show gradient background
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                ),
              )
            : const BoxDecoration(), // No decoration for inactive tab
        child: Center(
          child: Text(
            label, // Display tab name
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey, // Color depends on active state
            ),
          ),
        ),
      ),
    ),
  );
}

// Wrapper that holds both tabs (Income and Expenses) in a rounded container
Widget _buildSwitch() => Container(
  height: 50.h,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(40.r),
    border: Border.all(
      color: _gradientColor().withAlpha((0.4 * 255).toInt()), // Light orange border
      width: 1.2,
    ),
  ),
  child: Row(
    children: [
      _switchTab("Income", !isExpense), // Show income tab
      _switchTab("Expenses", isExpense), // Show expense tab
    ],
  ),
);

// Widget to enter the transaction amount with $ symbol and gradient styling
Widget _buildAmount() => Container(
  height: 80.h,
  padding: EdgeInsets.symmetric(horizontal: 24.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(40.r),
    border: Border.all(
      color: _gradientColor().withAlpha((0.4 * 255).toInt()),
      width: 1.2,
    ),
  ),
  child: Row(
    children: [
      // Dollar sign prefix
      Text("\$", style: GoogleFonts.poppins(fontSize: 22.sp, color: Colors.black54)),
      SizedBox(width: 12.w),
      Expanded(
        child: ShaderMask(
          // Apply a gradient to the input text
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: TextField(
            controller: amountController, // Amount input controller
            keyboardType: TextInputType.number, // Only numeric input
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 36.sp, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ],
  ),
);

// Generic widget used to render any input field with an icon on the left
Widget _inputField({
  required IconData icon, // Icon to show on left
  required Widget child, // TextField or Dropdown
  double iconSize = 20, // Size of the icon
}) =>
  Container(
    margin: EdgeInsets.only(bottom: 12.h), // Space below field
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: _gradientColor().withAlpha((0.3 * 255).toInt()), // Light orange border
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: iconSize, color: _gradientColor()), // Field icon
        SizedBox(width: 12.w),
        Expanded(child: child), // The actual input field or dropdown
      ],
    ),
  );

// Save button used to submit the form (calls saveTransaction)
// If saving is true, shows a loading spinner
Widget _buildSaveButton() => GestureDetector(
  onTap: isSaving ? null : saveTransaction, // Disable tap while saving
  child: Container(
    height: 52.h,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      gradient: const LinearGradient(
        colors: [Color(0xFFF57C00), Color(0xFFFFD54F)], // Orange-yellow gradient
      ),
    ),
    child: Center(
      child: isSaving
          ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
          : Text(
              "SAVE",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    ),
  ),
);

// Helper function to return an icon that represents a specific category
// Used in the dropdown UI to visually represent each category
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Transport': return Icons.directions_car;
    case 'Food': return Icons.fastfood;
    case 'Shopping': return Icons.shopping_bag;
    case 'Entertainment': return Icons.movie;
    case 'Health': return Icons.healing;
    case 'Bills': return Icons.receipt_long;
    case 'Travel': return Icons.flight;
    case 'Salary': return Icons.attach_money;
    case 'Freelance': return Icons.laptop_mac;
    case 'Business': return Icons.business_center;
    case 'Investment': return Icons.trending_up;
    case 'Gift': return Icons.card_giftcard;
    case 'Other': return Icons.help_outline;
    default: return Icons.category; // Fallback icon
  }
}
}