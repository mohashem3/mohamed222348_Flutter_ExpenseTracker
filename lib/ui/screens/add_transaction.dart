import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';
import 'package:mohamed222348_expense_tracker/services/transaction_service.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // ✅ accept optional transaction
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String selectedCategory = 'Transport';
  final amountController = TextEditingController(text: '0');
  final noteController = TextEditingController();
  final customCategoryController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  final List<String> expenseCategories = [
    'Transport', 'Food', 'Shopping', 'Entertainment', 'Health', 'Bills', 'Travel', 'Custom Category',
  ];

  final List<String> incomeCategories = [
    'Salary', 'Freelance', 'Business', 'Investment', 'Gift', 'Other', 'Custom Category',
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      isExpense = tx.isExpense;
      selectedCategory = incomeCategories.contains(tx.category) || expenseCategories.contains(tx.category)
          ? tx.category
          : 'Custom Category';
      if (selectedCategory == 'Custom Category') customCategoryController.text = tx.category;
      amountController.text = tx.amount.toString();
      noteController.text = tx.note;
      selectedDate = tx.date;
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> saveTransaction() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      showMessage('Enter a valid amount');
      return;
    }

    String category = selectedCategory == 'Custom Category'
        ? customCategoryController.text.trim()
        : selectedCategory;

    if (category.isEmpty) {
      showMessage('Category cannot be empty');
      return;
    }

    setState(() => isSaving = true);

    final service = TransactionService();
    final transaction = widget.transaction;

    if (transaction != null) {
      await service.updateTransaction(
        id: transaction.id,
        amount: double.parse(amountText),
        category: category,
        note: noteController.text.trim(),
        date: selectedDate,
        isExpense: isExpense,
      );
    } else {
      await service.addTransaction(
        amount: double.parse(amountText),
        category: category,
        note: noteController.text.trim(),
        date: selectedDate,
        isExpense: isExpense,
      );
    }

    showMessage('Transaction saved!', isSuccess: true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (context.mounted) Navigator.pop(context, 'updated');

  }

  void showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _gradientColor() => const Color(0xFFF57C00);

  @override
  Widget build(BuildContext context) {
    final categories = isExpense ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: const UpperBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Column(
              children: [
                _buildSwitch(),
                SizedBox(height: 24.h),
                _buildAmount(),
                SizedBox(height: 24.h),
                selectedCategory == 'Custom Category'
                    ? _inputField(
                        icon: Icons.edit,
                        child: TextField(
                          controller: customCategoryController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Enter category name',
                            hintStyle: GoogleFonts.poppins(),
                          ),
                        ),
                      )
                    : _inputField(
                        icon: getCategoryIcon(selectedCategory),
                        iconSize: 18.sp,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedCategory = value);
                              }
                            },
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
                _inputField(
                  icon: Icons.edit_note,
                  child: TextField(
                    controller: noteController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Note',
                      hintStyle: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _inputField(
                  icon: Icons.calendar_today,
                  child: GestureDetector(
                    onTap: pickDate,
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isExpense = label == "Expenses";
          selectedCategory = isExpense ? "Transport" : "Salary";
        }),
        child: Container(
          height: double.infinity,
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(40.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                  ),
                )
              : const BoxDecoration(),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch() => Container(
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(color: _gradientColor().withOpacity(0.4), width: 1.2),
        ),
        child: Row(
          children: [
            _switchTab("Income", !isExpense),
            _switchTab("Expenses", isExpense),
          ],
        ),
      );

  Widget _buildAmount() => Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(color: _gradientColor().withOpacity(0.4), width: 1.2),
        ),
        child: Row(
          children: [
            Text("\$", style: GoogleFonts.poppins(fontSize: 22.sp, color: Colors.black54)),
            SizedBox(width: 12.w),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
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

  Widget _inputField({required IconData icon, required Widget child, double iconSize = 20}) =>
      Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _gradientColor().withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize, color: _gradientColor()),
            SizedBox(width: 12.w),
            Expanded(child: child),
          ],
        ),
      );

  Widget _buildSaveButton() => GestureDetector(
        onTap: isSaving ? null : saveTransaction,
        child: Container(
          height: 52.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFF57C00), Color(0xFFFFD54F)],
            ),
          ),
          child: Center(
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
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
      default: return Icons.category;
    }
  }
}
