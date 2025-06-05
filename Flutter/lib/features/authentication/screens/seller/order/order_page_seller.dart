import 'package:ai_test/features/authentication/screens/dashboard/dashboard_seller.dart';
import 'package:ai_test/features/authentication/screens/seller/order/order_details_page_seller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class OrdersPageSeller extends StatefulWidget {
  const OrdersPageSeller({super.key});

  @override
  _OrdersPageSellerState createState() => _OrdersPageSellerState();
}

class _OrdersPageSellerState extends State<OrdersPageSeller> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller Orders')),
        body: const Center(child: Text('Please sign in to view orders')),
      );
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders');

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {

          // Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error}'));
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          // Display orders
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final orderId = doc.id;
              final userFullName = data['userFullName'] as String? ?? 'Unknown User Name';
              final totalItems = (data['totalItems'] as num?)?.toInt() ?? 0;
              final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

              return ListTile(
                title: Text(userFullName),
                subtitle: Text('Order ID: $orderId'),

                // Trailing widget
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Items: $totalItems'),
                    const SizedBox(height: 4),
                    Text(
                      'OMR ${totalAmount.toStringAsFixed(3)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onTap: () {

                  // Go to OrderDetailPageSeller
                  Get.to(() => OrderDetailPageSeller(orderId: orderId,));
                },
              );
            },
          );
        },
      ),

      // Return to dashboard
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Get.offAll(() => DashboardSeller()),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
