import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailPageUser extends StatelessWidget {
  final String orderId;
  const OrderDetailPageUser({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // User must be signed in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Please sign in to view order details')),
      );
    }

    final orderDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),

      // Load order document
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: orderDocRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final data = snapshot.data!.data()!;

          // Fetch order fields
          final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final sellerPhoneNumber = data['sellerPhoneNumber'] as String? ?? '';
          final status = data['status'] as String? ?? 'Pending';
          final items = (data['items'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();

          if (items.isEmpty) {
            return const Center(child: Text('No items in this order'));
          }

          // Header + each item
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount: OMR ${totalAmount.toStringAsFixed(3)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $status',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }

              final item = items[index - 1];
              final productName = item['productName'] as String? ?? '';
              final imageUrl = item['imageUrl'] as String? ?? '';
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              final sellerName = item['sellerName'] as String? ?? '';
              final priceText = 'OMR ${price.toStringAsFixed(3)}';
              final colorValue = item['selectedColor'] as String?;
              final Color? variantColor =
                  colorValue != null && colorValue.isNotEmpty
                      ? Color(int.parse(colorValue))
                      : null;

              return ListTile(
                contentPadding: EdgeInsets.zero,

                // Display product image
                leading: imageUrl.isNotEmpty
                    ? Image.network(imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.image_not_supported),
                      ),
                title: Text(productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seller: $sellerName'),
                    Text('Quantity: $quantity'),
                    Text('Price: $priceText'),
                    if (variantColor != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Color: '),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: variantColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
