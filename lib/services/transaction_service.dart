import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';

class TransactionService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance to access current user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance to interact with database

  Future<String?> addTransaction({
    required double amount, // Transaction amount
    required String category, // Transaction category (e.g., Food, Transport)
    required String note, // Additional note or description
    required DateTime date, // Date of transaction
    required bool isExpense, // Flag to indicate if it's an expense (true) or income (false)
  }) async {
    try {
      final user = _auth.currentUser; // Get the currently authenticated user
      if (user == null) return 'User not logged in.'; // If no user is logged in, return error

      final transaction = {
        'amount': amount, // Store amount
        'category': category, // Store category name
        'note': note, // Store note
        'date': Timestamp.fromDate(date), // Convert DateTime to Firestore-compatible Timestamp
        'type': isExpense ? 'expense' : 'income', // Store as a string for easy filtering
        'createdAt': FieldValue.serverTimestamp(), // Store creation timestamp from server
      };

      await _firestore
          .collection('users') // Go to 'users' collection
          .doc(user.uid) // Select document of current user
          .collection('transactions') // Go to subcollection 'transactions'
          .add(transaction); // Add the new transaction document

      return null; // Null means success
    } catch (e) {
      return 'Failed to add transaction: $e'; // Return error message on failure
    }
  }

  Future<String?> updateTransaction({
    required String id, // ID of the transaction document to update
    required double amount,
    required String category,
    required String note,
    required DateTime date,
    required bool isExpense,
  }) async {
    try {
      final user = _auth.currentUser; // Get current user
      if (user == null) return 'User not logged in.'; // Check for authentication

      final updatedData = {
        'amount': amount, // New amount
        'category': category, // New category
        'note': note, // Updated note
        'date': Timestamp.fromDate(date), // Updated date
        'type': isExpense ? 'expense' : 'income', // Updated type
      };

      await _firestore
          .collection('users') // Navigate to 'users' collection
          .doc(user.uid) // Locate user document
          .collection('transactions') // Navigate to user's 'transactions'
          .doc(id) // Select the transaction by its ID
          .update(updatedData); // Apply the updates

      return null; // Null means success
    } catch (e) {
      return 'Failed to update transaction: $e'; // Return error message on failure
    }
  }

 Future<List<TransactionModel>> getAllTransactions({bool? isExpense}) async {
  final user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
  if (user == null) return []; // If user is not logged in, return empty list

  Query query = FirebaseFirestore.instance
      .collection('users') // Access 'users' collection
      .doc(user.uid) // Get current user's document
      .collection('transactions'); // Access 'transactions' subcollection

  if (isExpense != null) {
    // If a filter is provided (true for expense, false for income)
    query = query.where('type', isEqualTo: isExpense ? 'expense' : 'income'); // Apply the filter
  }

  final snapshot = await query.get(); // Execute the query

  return snapshot.docs
      .map((doc) => TransactionModel.fromDocument(doc)) // Convert each doc to TransactionModel
      .toList(); // Return as list
}

// ✅ NEW: Delete Transaction
Future<String?> deleteTransaction(String id) async {
  try {
    final user = _auth.currentUser; // Get current user
    if (user == null) return 'User not logged in.'; // Return error if not logged in

    await _firestore
        .collection('users') // Access 'users' collection
        .doc(user.uid) // Get current user's document
        .collection('transactions') // Access 'transactions' subcollection
        .doc(id) // Get specific transaction by ID
        .delete(); // Delete the document

    return null; // Null indicates success
  } catch (e) {
    return 'Failed to delete transaction: $e'; // Return error message on failure
  }
}

Future<Map<String, double>> calculateTotals() async {
  final user = _auth.currentUser; // Get the current user
  if (user == null) return {'income': 0, 'expense': 0, 'balance': 0}; // Return zeros if no user

  final query = await _firestore
      .collection('users') // Access 'users' collection
      .doc(user.uid) // Get current user's document
      .collection('transactions') // Access 'transactions' subcollection
      .get(); // Fetch all transaction documents

  double income = 0; // Track total income
  double expense = 0; // Track total expense

  for (var doc in query.docs) {
    final data = doc.data(); // Get the document data
    final amount = (data['amount'] ?? 0).toDouble(); // Parse amount safely
    final type = data['type'] ?? 'expense'; // Default type to 'expense'

    if (type == 'income') {
      income += amount; // Add to income total
    } else {
      expense += amount; // Add to expense total
    }
  }

  return {
    'income': income, // Total income
    'expense': expense, // Total expenses
    'balance': income - expense, // Balance = income - expenses
  };
}
}
