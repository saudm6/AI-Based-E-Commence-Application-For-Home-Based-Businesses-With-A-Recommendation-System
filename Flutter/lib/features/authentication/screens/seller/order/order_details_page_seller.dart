import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailPageSeller extends StatelessWidget {
  final String orderId;
  const OrderDetailPageSeller({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final sellerUser = FirebaseAuth.instance.currentUser;
    if (sellerUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Please sign in to view order details')),
      );
    }

    final sellerOrderDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(sellerUser.uid)
        .collection('orders')
        .doc(orderId);

    // Stock reduction + updates order status
    Future<void> _runConfirmationTransaction() async {
      final db = FirebaseFirestore.instance;
      final newStatus = 'Confirmed';

      // Loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirming order and updating stock...'), duration: Duration(seconds: 2)),
      );

      try {
        await db.runTransaction((tx) async {

          // Read sellers order
          final orderSnap = await tx.get(sellerOrderDocRef);
          if (!orderSnap.exists || orderSnap.data() == null) {
            throw Exception("Seller order document not found!");
          }
          final orderData = orderSnap.data()!;
          final items = (orderData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          // Decrement quantity for each item
          for (final item in items) {
            final pid = item['productId'] as String?;
            final rawSel = item['selectedColor'] as String?;
            final qtyOrdered = (item['quantity'] as num?)?.toInt();

            if (pid == null || rawSel == null || qtyOrdered == null || qtyOrdered <= 0) {
              continue;
            }

            final selHex = rawSel.replaceFirst('0x', '');
            final prodRef = db.collection('products').doc(pid);
            final prodSnap = await tx.get(prodRef);

            // Check if the product document exists
            if (!prodSnap.exists || prodSnap.data() == null) {
              continue;
            }

            // Get colorVariants
            final variants = (prodSnap.data()!['colorVariants'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            bool variantFound = false;
            final updated = variants.map((v) {
              if ((v['color'] as String?) == selHex) {
                variantFound = true;
                final currentQty = (v['quantity'] as num?)?.toInt() ?? 0;
                return {
                  'color': v['color'],

                  // Calculate new quantity
                  'quantity': (currentQty - qtyOrdered < 0) ? 0 : currentQty - qtyOrdered,
                };
              }
              return v;
            }).toList();

            // Check colorVariants
            if (variantFound) {
              tx.update(prodRef, {'colorVariants': updated});
            }
          }

          // Update seller order status
          tx.update(sellerOrderDocRef, {'status': newStatus});
        });
      } catch (e) {
        rethrow;
      }
    }

    // Updates status
    Future<void> _updateStatusForAll(String newStatus, String customerId, BuildContext context) async {
      if (customerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error')),
        );
        return;
      }

      final customerOrderDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .collection('orders')
          .doc(orderId);

      // Update order status
      try {
        await sellerOrderDocRef.update({'status': newStatus});
        await customerOrderDocRef.update({'status': newStatus});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status changed')),
        );
      } catch (e) {
        // Error state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }


    // Listen to real time changes
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: sellerOrderDocRef.snapshots(),
      builder: (context, snapshot) {
        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // Loading state
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
              appBar: AppBar(title: const Text('Order Details')),
              body: const Center(child: CircularProgressIndicator())
          );
        }

        // Extract data
        final data = snapshot.data!.data()!;
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final status = data['status'] as String? ?? 'Pending';
        final userFullName = data['userFullName'] as String? ?? 'N/A';
        final userPhoneNumber = data['userPhoneNumber'] as String? ?? 'N/A';
        final items = (data['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        final customerId = data['userId'] as String?;

        // Decides buttons
        Widget? buildButtons() {
          if (customerId == null || customerId.isEmpty) {
            return null;
          }

          List<Widget> buttons = [];

          // Scenario 1: Pending
          if (status == 'Pending') {
            buttons = [
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _runConfirmationTransaction();
                    await _updateStatusForAll('Confirmed', customerId, context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error confirming order: $e')),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                onPressed: () async {
                  await _updateStatusForAll('Cancelled', customerId, context);
                },
                child: const Text('Cancel'),
              ),
            ];
          }

          // Scenario 2: Confirmed
          else if (status == 'Confirmed') {
            buttons = [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                onPressed: () async {
                  await _updateStatusForAll('Delivered', customerId, context);
                },
                child: const Text('Deliver'),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                onPressed: () async {
                  await _updateStatusForAll('Cancelled', customerId, context);
                },
                child: const Text('Cancel'),
              ),
            ];
          }

          // Scenario 3: Delivered or Cancelled
          else if (status == 'Delivered' || status == 'Cancelled') {
            buttons = [];
          }
          else {
            buttons = [];
          }
          if (buttons.isEmpty) {
            return null;
          }

          // Return the row if there are buttons
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            ),
          );
        }

        // UI
        return Scaffold(
          appBar: AppBar(title: const Text('Order Details')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16.0),

            // Item count
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {

              // Header Section
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: $orderId',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Amount: OMR ${totalAmount.toStringAsFixed(3)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status == 'Pending' ? Colors.orange :
                          status == 'Confirmed' ? Colors.blue :
                          status == 'Delivered' ? Colors.green :
                          status == 'Cancelled' ? Colors.red : Colors.black,
                        )),
                    const SizedBox(height: 12),
                    Text('Customer: $userFullName',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Phone: $userPhoneNumber',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                );
              }

              // Item Section
              final itemIndex = index - 1;
              if (itemIndex < 0 || itemIndex >= items.length) {
                return const SizedBox.shrink();
              }
              final item = items[itemIndex];
              final productName = item['productName'] as String? ?? 'N/A';
              final imageUrl = item['imageUrl'] as String? ?? '';
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              final priceText = 'OMR ${price.toStringAsFixed(3)}';
              final colorValue = item['selectedColor'] as String?;
              final Color? variantColor =
              colorValue != null && colorValue.startsWith('0x') && colorValue.length == 10
                  ? Color(int.parse(colorValue))
                  : null;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                leading: imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,

                    // Error for network image
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(width: 60, height: 60, child: Icon(Icons.broken_image, size: 30)),
                    loadingBuilder:(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null ?
                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey,),
                ),
                title: Text(productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: $quantity'),
                    Text('Price per item: $priceText'),
                    // Show variant color
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
                              border: Border.all(color: Colors.black38, width: 1.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                // Total Price
                trailing: Text(
                  'OMR ${(price * quantity).toStringAsFixed(3)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          bottomNavigationBar: buildButtons(),
        );
      },
    );
  }
}