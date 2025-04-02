import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final String type; // Add this to expose 'income' or 'expense' string

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.type,
  });

  bool get isExpense => type == 'expense'; // Derived property for convenience

  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'expense', // Default to expense if missing
    );
  }
}
