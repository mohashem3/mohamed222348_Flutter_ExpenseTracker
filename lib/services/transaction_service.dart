import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mohamed222348_expense_tracker/model/transaction_model.dart';

class TransactionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> addTransaction({
    required double amount,
    required String category,
    required String note,
    required DateTime date,
    required bool isExpense,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in.';

      final transaction = {
        'amount': amount,
        'category': category,
        'note': note,
        'date': Timestamp.fromDate(date),
        'type': isExpense ? 'expense' : 'income',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add(transaction);

      return null;
    } catch (e) {
      return 'Failed to add transaction: $e';
    }
  }

  Future<String?> updateTransaction({
    required String id,
    required double amount,
    required String category,
    required String note,
    required DateTime date,
    required bool isExpense,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in.';

      final updatedData = {
        'amount': amount,
        'category': category,
        'note': note,
        'date': Timestamp.fromDate(date),
        'type': isExpense ? 'expense' : 'income',
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(id)
          .update(updatedData);

      return null;
    } catch (e) {
      return 'Failed to update transaction: $e';
    }
  }

  Future<List<TransactionModel>> getAllTransactions({bool? isExpense}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  Query query = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('transactions');

  if (isExpense != null) {
    query = query.where('type', isEqualTo: isExpense ? 'expense' : 'income');
  }

  final snapshot = await query.get();

  return snapshot.docs
      .map((doc) => TransactionModel.fromDocument(doc))
      .toList();
}


  // ✅ NEW: Delete Transaction
  Future<String?> deleteTransaction(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in.';

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(id)
          .delete();

      return null;
    } catch (e) {
      return 'Failed to delete transaction: $e';
    }
  }

  Future<Map<String, double>> calculateTotals() async {
  final user = _auth.currentUser;
  if (user == null) return {'income': 0, 'expense': 0, 'balance': 0};

  final query = await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('transactions')
      .get();

  double income = 0;
  double expense = 0;

  for (var doc in query.docs) {
    final data = doc.data();
    final amount = (data['amount'] ?? 0).toDouble();
    final type = data['type'] ?? 'expense';

    if (type == 'income') {
      income += amount;
    } else {
      expense += amount;
    }
  }

  return {
    'income': income,
    'expense': expense,
    'balance': income - expense,
  };
}
}

