import 'package:cloud_firestore/cloud_firestore.dart';

// Model class representing a single transaction
class TransactionModel {
  final String id; // Unique Firestore document ID for the transaction
  final double amount; // Transaction amount
  final String category; // Category of the transaction (e.g., Food, Travel)
  final String note; // Optional user note about the transaction
  final DateTime date; // Date and time the transaction occurred
  final String type; // Either 'income' or 'expense'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.type,
  });

  // Convenience getter to check if the transaction is an expense
  bool get isExpense => type == 'expense';

  // Factory constructor to convert Firestore document into a TransactionModel
  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Safely cast document data to map

    return TransactionModel(
      id: doc.id, // Use Firestore's auto-generated document ID as the transaction ID
      amount: (data['amount'] ?? 0).toDouble(), // Safely convert amount to double
      category: data['category'] ?? '', // Provide empty string fallback
      note: data['note'] ?? '', // Provide empty string fallback
      date: (data['date'] as Timestamp).toDate(), // Convert Firestore timestamp to DateTime
      type: data['type'] ?? 'expense', // Default to 'expense' if type is missing
    );
  }
}
