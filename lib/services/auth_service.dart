import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This service handles all authentication-related operations,
/// including sign-up, login, logout, and profile updates.
/// It also integrates Firestore to store additional user data like names and timestamps.
class AuthService {
  // Firebase Auth instance for managing authentication (sign up, login, logout)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance for storing extra user information in the 'users' collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a new user using email and password,
  /// and saves additional profile data (name, createdAt) in Firestore.
  ///
  /// Returns `null` if successful, or an error message string if it fails.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to create a new user with email and password
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store the user's name and creation timestamp in Firestore under their UID
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return null; // Indicates success
    } on FirebaseAuthException catch (e) {
      // Returns a descriptive error message from Firebase if auth fails
      return e.message;
    } catch (e) {
      // Fallback message for any other unexpected error
      return 'Something went wrong. Please try again.';
    }
  }

  /// Logs in an existing user using email and password.
  ///
  /// Returns `null` if successful, or an error message string if it fails.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Indicates success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login failed. Please try again.';
    }
  }

  /// Logs the current user out of the application.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Provides direct access to the currently logged-in user.
  User? get currentUser => _auth.currentUser;

  /// Updates the current user's display name in Firestore.
  ///
  /// Returns `null` if successful, or an error message string if it fails.
  Future<String?> updateUsername(String newName) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'No user found.';

      await _firestore.collection('users').doc(uid).update({
        'name': newName,
      });

      return null; // Indicates success
    } catch (e) {
      return 'Failed to update username.';
    }
  }

  /// Re-authenticates the user using their current password.
  /// This is required before sensitive operations like changing password.
  ///
  /// Returns `null` if successful, or an error message string if it fails.
  Future<String?> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return 'No user found.';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return null; // Indicates successful reauthentication
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Reauthentication failed.';
    }
  }

  /// Updates the user's password after they have been reauthenticated.
  ///
  /// Returns `null` if successful, or an error message string if it fails.
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      return null; // Indicates success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to update password.';
    }
  }
}
