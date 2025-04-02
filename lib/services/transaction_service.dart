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

  Stream<List<TransactionModel>> getTransactions({
    required bool isExpense,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    Query query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .where('type', isEqualTo: isExpense ? 'expense' : 'income')
        .orderBy('date', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromDocument(doc))
          .toList();
    });
  }
}
