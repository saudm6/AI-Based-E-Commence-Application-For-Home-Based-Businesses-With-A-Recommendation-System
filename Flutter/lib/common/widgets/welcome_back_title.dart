import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget welcomeBackTitle(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  // Display if user is not logged in
  if (user == null) {
    return const Text('Not Logged In');
  }

  // Returns text + full name
  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(),
    builder: (ctx, snap) {

      // Temp response
      if (snap.connectionState == ConnectionState.waiting) {
        return const Text('Welcome back…');
      }

      // Extract map data
      final data = snap.data?.data();

      // Display storeName
      final fullName = data?['storeName'] as String? ??
          user.displayName ??
          'User';

      // Final Text that is displayed
      return Text('Welcome, $fullName');
    },
  );
}
