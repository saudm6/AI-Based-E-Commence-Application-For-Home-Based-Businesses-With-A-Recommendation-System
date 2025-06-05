import 'package:ai_test/features/authentication/screens/admin/admin_dashboard.dart';
import 'package:ai_test/features/authentication/screens/dashboard/dashboard_seller.dart';
import 'package:ai_test/features/authentication/screens/user/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Error state
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
              body: Center(child: Text('No user data found')));
        }

        // Default user role
        Map<String, dynamic> userData =
        snapshot.data!.data() as Map<String, dynamic>;
        String role = userData['role'] ?? 'user';

        // Go to dashboard depending on role
        if (role == 'admin') {
          return AdminDashboard();
        } else if (role == 'seller') {
          return DashboardSeller();
        } else {
          return UserDashboard();
        }
      },
    );
  }
}

