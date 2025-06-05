import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders/confirm_order.dart';

class CartPageUser extends StatefulWidget {
  const CartPageUser({super.key});

  @override
  State<CartPageUser> createState() => _CartPageUserState();
}

class _CartPageUserState extends State<CartPageUser> {

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: const Center(child: Text('Please sign in to view your cart')),
      );
    }
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: cartRef.snapshots(),
              builder: (context, snapshot) {

                // Error state, loading state, empty state
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));}

                // Scrollable cart
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final d = doc.data();
                    final qty = (d['quantity'] as num).toInt();
                    final price = (d['price'] as num).toDouble();
                    final priceText = 'OMR ${price.toStringAsFixed(3)}';
                    final colorHex = d['selectedColor'] as String? ?? '';
                    final variant = colorHex.isNotEmpty ? Color(int.parse(colorHex)) : Colors.transparent;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (d['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                d['imageUrl'] as String,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 12),

                          // Product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['storeName'] as String? ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  d['productName'] as String? ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: $priceText',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Color: '),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: variant,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Add or increase quantity
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => cartRef.doc(doc.id).update({'quantity': FieldValue.increment(1)}),
                              ),
                              Text(qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (qty > 1) {
                                    cartRef.doc(doc.id).update({'quantity': FieldValue.increment(-1)});
                                  } else {
                                    cartRef.doc(doc.id).delete();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Total price
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: cartRef.snapshots(),
            builder: (context, snapshot) {
              double total = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final d = doc.data();
                  final qty = (d['quantity'] as num).toInt();
                  final price = (d['price'] as num).toDouble();
                  total += price * qty;
                }
              }
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Total:',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      'OMR ${total.toStringAsFixed(3)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),

          // Confirm Order button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await confirmOrder(context);
                },
                child: const Text('Confirm Order'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}