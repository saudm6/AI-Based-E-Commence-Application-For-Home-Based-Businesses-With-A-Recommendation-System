import 'package:ai_test/features/authentication/screens/user/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_test/features/authentication/screens/admin/admin_dashboard.dart';
import 'package:ai_test/features/authentication/screens/dashboard/dashboard_seller.dart';

class RoleBasedController extends StatelessWidget {
  const RoleBasedController({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Empty state
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
              body: Center(child: Text('No user data found')));
        }

        // Extract user role
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] ?? "user";

        // Send user to dashboard
        if (role == 'admin') {
          return const AdminDashboard();
        } else if (role == 'seller') {
          return const DashboardSeller();
        } else {
          return const UserDashboard();
        }
      },
    );
  }
}
