import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/bottom_bar.dart';
import 'package:mohamed222348_expense_tracker/ui/widgets/upper_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int selectedIndex = 2;
  String name = '';
  String email = '';
  String initials = '';

  bool isEditingName = false;
  bool isEditingPassword = false;
  bool isPasswordEditable = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        name = doc['name'] ?? '';
        email = doc['email'] ?? '';
        initials = _getInitials(name);
        nameController.text = name;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  }

  void _onTabSelected(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/list');
    }
    else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/stats');
    }
    else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveUsername() async {
    final newName = nameController.text.trim();
    if (newName.length < 3) {
      _showSnack("Name must be at least 3 characters", error: true);
      return;
    }

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'name': newName});
      setState(() {
        name = newName;
        initials = _getInitials(newName);
        isEditingName = false;
      });
      _showSnack("Name updated successfully!");
    } catch (e) {
      _showSnack("Failed to update name", error: true);
    }
  }

  Future<void> _reauthenticateAndAllowPasswordEdit() async {
    final controller = TextEditingController();
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final cred = EmailAuthProvider.credential(
                email: email,
                password: controller.text,
              );

              try {
  await _auth.currentUser!.reauthenticateWithCredential(cred);
  if (!mounted) return;

  Navigator.pop(context);
  setState(() => isPasswordEditable = true);
  _showSnack("Authentication successful!");
} catch (e) {
  if (!mounted) return;

  Navigator.pop(context);
  _showSnack("Wrong password", error: true);
}

            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword() async {
    final newPassword = passwordController.text.trim();
    if (newPassword.length < 6) {
      _showSnack("Password must be at least 6 characters", error: true);
      return;
    }

    try {
      await _auth.currentUser!.updatePassword(newPassword);
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


// Future<bool> _requestStoragePermission() async {
//   final status = await Permission.storage.request();
//   if (status.isGranted) {
//     return true;
//   } else {
//     _showSnack("Storage permission denied", error: true);
//     return false;
//   }
// }

 Future<void> _exportData() async {
  final user = _auth.currentUser;
  if (user == null) return;

  // 🔥 Get user name from Firestore
  final userDoc = await _firestore.collection('users').doc(user.uid).get();
  final userName = (userDoc.data()?['name'] ?? 'user').toString().replaceAll(' ', '_');

  final snapshot = await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('transactions')
      .get();

  if (snapshot.docs.isEmpty) {
    _showSnack("No transactions to export", error: true);
    return;
  }

  // ✅ Request permission
  if (await Permission.manageExternalStorage.isDenied ||
      await Permission.manageExternalStorage.isPermanentlyDenied) {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showSnack("Storage permission denied", error: true);
      return;
    }
  }

  final buffer = StringBuffer();
  buffer.writeln("Amount,Category,Note,Type,Date");

  for (var doc in snapshot.docs) {
    final data = doc.data();
    buffer.writeln(
      '${data['amount']},${data['category']},${data['note']},${data['type']},${DateFormat('yyyy-MM-dd – kk:mm').format((data['date'] as Timestamp).toDate())}',
    );
  }

  // ✅ Include username in filename
  final dir = Directory('/storage/emulated/0/Download');
  final file = File('${dir.path}/${userName}_budgetbuddy_export.csv');
  await file.writeAsString(buffer.toString());

  _showSnack("Exported to ${file.path}");
}

Future<void> _handleLogout() async {
  await _auth.signOut();

  // Check if the widget is still in the tree
  if (!mounted) return;

  Navigator.pushReplacementNamed(context, '/login');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UpperBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 45.r,
                backgroundColor: Colors.deepOrange,
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30.h),

              _buildField(
                label: "Username",
                controller: nameController,
                editable: isEditingName,
                onEdit: () => setState(() => isEditingName = true),
                onSave: _saveUsername,
              ),
              SizedBox(height: 18.h),

              _buildField(
                label: "Email",
                controller: TextEditingController(text: email),
                editable: false,
              ),
              SizedBox(height: 18.h),

              _buildField(
                label: "Password",
                controller: passwordController,
                editable: isPasswordEditable,
                onEdit: _reauthenticateAndAllowPasswordEdit,
                onSave: _updatePassword,
                obscureText: true,
              ),
              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _exportData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Export Data", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: selectedIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: () => Navigator.pushNamed(context, '/add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CenterFAB(onPressed: () => Navigator.pushNamed(context, '/add')),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool editable,
    VoidCallback? onEdit,
    VoidCallback? onSave,
    bool obscureText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: editable,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: editable ? Colors.orange.shade50 : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        if (onEdit != null && !editable)
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.deepOrange)),
        if (editable && onSave != null)
          IconButton(onPressed: onSave, icon: const Icon(Icons.check_circle, color: Colors.green)),
      ],
    );
  }
}
