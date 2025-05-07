// Dart and Flutter core imports
import 'dart:io'; // For handling file system operations (used in data export feature)
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore access (user data, transactions)
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication and credential management
import 'package:flutter/material.dart'; // Core Flutter UI framework
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Responsive layout utility
import 'package:google_fonts/google_fonts.dart'; // Allows custom fonts from Google Fonts
import 'package:intl/intl.dart'; // Date formatting utilities
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart'; // Reusable bottom navigation bar
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart'; // Reusable app top bar
import 'package:permission_handler/permission_handler.dart'; // For runtime storage permission handling

// Main ProfileScreen class – Stateful because it manages user input, edits, and dynamic content updates
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase authentication and Firestore references used throughout the profile
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Index for bottom navigation bar to highlight 'Profile' tab by default
  int selectedIndex = 2;

  // User-related fields: fetched from Firestore
  String name = '';       // Full name of the user
  String email = '';      // Email of the user (read-only)
  String initials = '';   // User initials (for avatar display)

  // Flags to manage UI edit modes
  bool isEditingName = false;         // Enables username field for editing
  bool isEditingPassword = false;     // Triggers password edit logic
  bool isPasswordEditable = false;    // Becomes true after successful reauthentication

  // Controllers for editable fields
  final TextEditingController nameController = TextEditingController();      // Controls name input field
  final TextEditingController passwordController = TextEditingController();  // Controls password input field

  // Called once when widget is inserted in the widget tree
  @override
  void initState() {
    super.initState();
    _loadUserData(); // Fetch user details (name, email, initials) from Firestore
  }

  // Fetches user data from Firestore and populates relevant fields
  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        name = doc['name'] ?? '';                  // Set name from Firestore, fallback to empty string
        email = doc['email'] ?? '';                // Set email (non-editable)
        initials = _getInitials(name);             // Extract initials from full name
        nameController.text = name;                // Pre-fill name input field
      });
    }
  }

  // Utility function to get uppercase initials from user's full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase(); // Single-word name
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase(); // First letters of first two words
  }

  // Handles navigation tab switching via BottomBar
  void _onTabSelected(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');    // Navigate to Home
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/list');    // Navigate to Transaction List
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/stats');   // Navigate to Stats
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile'); // Stay on Profile
    }
  }

  // Shows a floating snackbar with success or error styling
  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Validates and updates the user's name in Firestore
  Future<void> _saveUsername() async {
    final newName = nameController.text.trim();
    if (newName.length < 3) {
      _showSnack("Name must be at least 3 characters", error: true); // Validation failure
      return;
    }

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'name': newName});
      setState(() {
        name = newName;                        // Update displayed name
        initials = _getInitials(newName);      // Recalculate initials
        isEditingName = false;                 // Exit edit mode
      });
      _showSnack("Name updated successfully!"); // Success message
    } catch (e) {
      _showSnack("Failed to update name", error: true); // Handle update error
    }
  }

  // Prompts reauthentication via password before enabling password update
  Future<void> _reauthenticateAndAllowPasswordEdit() async {
    final controller = TextEditingController(); // For password input in dialog

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Re-authenticate"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Enter current password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final cred = EmailAuthProvider.credential(
                email: email,                  // Use stored email
                password: controller.text,     // Password entered by user
              );

              try {
                await _auth.currentUser!.reauthenticateWithCredential(cred); // Firebase reauthentication
                if (!mounted) return;
                Navigator.pop(context);       // Close dialog
                setState(() => isPasswordEditable = true); // Allow password editing
                _showSnack("Authentication successful!");  // Show confirmation
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);       // Close dialog
                _showSnack("Wrong password", error: true); // Show error
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }


  // Updates the user's password after validation and reauthentication
Future<void> _updatePassword() async {
  final newPassword = passwordController.text.trim();

  // Validate password length before attempting update
  if (newPassword.length < 6) {
    _showSnack("Password must be at least 6 characters", error: true);
    return;
  }

  try {
    // Firebase method to update password for the current user
    await _auth.currentUser!.updatePassword(newPassword);

    // Reset UI states after successful update
    setState(() {
      isEditingPassword = false;
      isPasswordEditable = false;
      passwordController.clear();
    });

    _showSnack("Password updated successfully!");
  } catch (e) {
    _showSnack("Failed to update password", error: true);
  }
}

// Exports user's transactions to a CSV file saved in Downloads directory
Future<void> _exportData() async {
  final user = _auth.currentUser;
  if (user == null) return;

  // Fetch user’s name from Firestore to use in file naming
  final userDoc = await _firestore.collection('users').doc(user.uid).get();
  final userName = (userDoc.data()?['name'] ?? 'user').toString().replaceAll(' ', '_');

  // Fetch all transaction documents under the user’s subcollection
  final snapshot = await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('transactions')
      .get();

  // Exit early if user has no transactions to export
  if (snapshot.docs.isEmpty) {
    _showSnack("No transactions to export", error: true);
    return;
  }

  // Request manage external storage permission if not already granted
  if (await Permission.manageExternalStorage.isDenied ||
      await Permission.manageExternalStorage.isPermanentlyDenied) {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showSnack("Storage permission denied", error: true);
      return;
    }
  }

  // Build the CSV content using a string buffer
  final buffer = StringBuffer();
  buffer.writeln("Amount,Category,Note,Type,Date"); // Header row

  for (var doc in snapshot.docs) {
    final data = doc.data();

    // Format each transaction into a CSV row
    buffer.writeln(
      '${data['amount']},'
      '${data['category']},'
      '${data['note']},'
      '${data['type']},'
      '${DateFormat('yyyy-MM-dd – kk:mm').format((data['date'] as Timestamp).toDate())}',
    );
  }

  // Write the data to a CSV file in the Downloads directory
  final dir = Directory('/storage/emulated/0/Download');
  final file = File('${dir.path}/${userName}_budgetbuddy_export.csv');
  await file.writeAsString(buffer.toString());

  _showSnack("Exported to ${file.path}"); // Show success message
}

// Signs the user out of Firebase and navigates to the login screen
Future<void> _handleLogout() async {
  await _auth.signOut();

  // Ensure the widget is still mounted before navigating
  if (!mounted) return;

  Navigator.pushReplacementNamed(context, '/login');
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const UpperBar(), // Reusable custom app bar at the top

    body: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Center(
        child: Column(
          children: [
            // Circular avatar showing the user's initials
            CircleAvatar(
              radius: 45.r,
              backgroundColor: Colors.deepOrange,
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // Editable username field
            _buildField(
              label: "Username",
              controller: nameController,
              editable: isEditingName,
              onEdit: () => setState(() => isEditingName = true),
              onSave: _saveUsername,
            ),

            SizedBox(height: 18.h),

            // Non-editable email field
            _buildField(
              label: "Email",
              controller: TextEditingController(text: email),
              editable: false,
            ),

            SizedBox(height: 18.h),

            // Editable password field (only after reauthentication)
            _buildField(
              label: "Password",
              controller: passwordController,
              editable: isPasswordEditable,
              onEdit: _reauthenticateAndAllowPasswordEdit,
              onSave: _updatePassword,
              obscureText: true,
            ),

            SizedBox(height: 30.h),

            // Export button for downloading all transactions as CSV
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exportData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Export Data",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    ),

    // Bottom navigation and FAB setup
    bottomNavigationBar: BottomBar(
      currentIndex: selectedIndex,
      onTabSelected: _onTabSelected,
      onFabPressed: () => Navigator.pushNamed(context, '/add'),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    floatingActionButton: CenterFAB(onPressed: () => Navigator.pushNamed(context, '/add')),
  );
}


  // Reusable widget to build a labeled input field with optional editing and saving controls
Widget _buildField({
  required String label,                      // Label shown above the input field
  required TextEditingController controller, // Controller that holds the current input value
  required bool editable,                    // Determines if the field is editable or read-only
  VoidCallback? onEdit,                      // Optional function to call when edit icon is pressed
  VoidCallback? onSave,                      // Optional function to call when save (check) icon is pressed
  bool obscureText = false,                  // Optional: hides text input for sensitive fields like passwords
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end, // Aligns the text field and icons to the bottom
    children: [
      // Main input field occupying remaining width
      Expanded(
        child: TextField(
          controller: controller,         // Connects the text field to the passed-in controller
          enabled: editable,              // Enables editing based on the editable flag
          obscureText: obscureText,       // Obscures text for password fields
          decoration: InputDecoration(
            labelText: label,             // Displays field label inside the border
            filled: true,                 // Enables background fill
            fillColor: editable           // Color indicates editable (orange) or view-only (gray)
                ? Colors.orange.shade50
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), // Rounded corners using responsive radius
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ),
      SizedBox(width: 8.w), // Space between the field and the icon

      // Show edit icon if field is not editable and edit handler is provided
      if (onEdit != null && !editable)
        IconButton(
          onPressed: onEdit, // Triggers the edit mode toggle
          icon: const Icon(Icons.edit, color: Colors.deepOrange),
        ),

      // Show save icon if field is currently editable and save handler is provided
      if (editable && onSave != null)
        IconButton(
          onPressed: onSave, // Commits the changes by calling the save function
          icon: const Icon(Icons.check_circle, color: Colors.green),
        ),
    ],
  );
}
}