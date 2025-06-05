import 'package:ai_test/features/authentication/screens/user/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'order_detail_page_user.dart';

// Order model
class Order {
  final String id;
  final String storeName;
  final double totalAmount;
  final int totalItems;

  Order({
    required this.id,
    required this.storeName,
    required this.totalAmount,
    required this.totalItems,
  });
}

// Display all orders
class OrdersPageUser extends StatefulWidget {
  const OrdersPageUser({super.key});

  @override
  _OrdersPageUserState createState() => _OrdersPageUserState();
}

class _OrdersPageUserState extends State<OrdersPageUser> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user signed in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Orders')),
        body: const Center(child: Text('Please sign in to view your orders')),
      );
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('You have no orders yet'));
          }

          // Display orders
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final orderId = data['orderId'] as String? ?? doc.id;
              final storeName = data['storeName'] as String? ?? 'Unknown Store';
              final totalItems = (data['totalItems'] as num?)?.toInt() ?? 0;
              final totalAmount =
                  (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

              return ListTile(
                title: Text(storeName),
                subtitle: Text('Order ID: ' + orderId),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Items: ${totalItems.toStringAsFixed(3)}'),
                    const SizedBox(height: 4),
                    Text(
                      'OMR ${totalAmount.toStringAsFixed(3)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onTap: () {

                  // Go to OrderDetailPageUser
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPageUser(orderId: orderId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // Go to user dashboard
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Confirm order
            Get.offAll(() => const UserDashboard());
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
