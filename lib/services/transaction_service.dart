import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      return null; // success
    } catch (e) {
      return 'Failed to add transaction: $e';
    }
  }
}
