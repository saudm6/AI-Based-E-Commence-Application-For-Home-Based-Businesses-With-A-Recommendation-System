import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_page_user.dart';

Future<void> confirmOrder(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  // Check if user signed in
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in to confirm order')),
    );
    return;
  }
  final uid = user.uid;

  // Get user phone number & username & storeName
  final userDoc =
  await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final userPhone = userDoc.data()?['phoneNumber']?.toString() ?? '';
  final userName =
      userDoc.data()?['username'] as String? ?? user.displayName ?? '';
  final userStoreName = userDoc.data()?['storeName'] as String? ?? '';

  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('cart');
  final userOrdersRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('orders');

  final cartSnap = await cartRef.get();

  // Cart empty
  if (cartSnap.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your cart is empty')),
    );
    return;

  }

  try {
    double totalAmount = 0;
    int totalItems = 0;
    String storeName = '';
    String? firstProdId;

    // Build the items list
    final items = cartSnap.docs.map((doc) {
      final d = doc.data();
      final price = (d['price'] as num).toDouble();
      final qty = (d['quantity'] as num).toInt();
      totalAmount += price * qty;
      totalItems += qty;
      storeName =
          storeName.isEmpty ? (d['storeName'] as String? ?? '') : storeName;
      firstProdId ??= d['productId'] as String?;
      return {
        'productId': d['productId'] as String? ?? '',
        'productName': d['productName'] as String? ?? '',
        'imageUrl': d['imageUrl'] as String? ?? '',
        'quantity': qty,
        'price': price,
        'sellerName': d['storeName'] as String? ?? '',
        'selectedColor': d['selectedColor'] as String? ?? '',
      };
    }).toList();

    // Check if Item is in stock
    for (final item in items) {
      final pid = item['productId'] as String;
      final requestedQty = item['quantity'] as int;

      // Carts selectedColor
      final rawSel = item['selectedColor'] as String? ?? '';
      final selHex = rawSel.replaceFirst('0x', '');

      final prodSnap = await FirebaseFirestore.instance
          .collection('products')
          .doc(pid)
          .get();

      if (!prodSnap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product no longer exists')),
        );
        return;
      }

      final data = prodSnap.data()!;


      final variants = (data['colorVariants'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? const [];

      int availableQty;

      // If not using colour variants, read the quantity field
      if (variants.isEmpty) {
        availableQty = (data['quantity'] as num?)?.toInt() ?? 0;
      } else {
        final rawSel = item['selectedColor'] as String? ?? '';
        final selNorm = rawSel.toUpperCase().replaceFirst(RegExp(r'^0X'), '');
        final match = variants.firstWhere(
                (v) => (v['color'] as String).toUpperCase().replaceFirst(RegExp(r'^0X'), '') == selNorm,
            orElse: () => {});
        availableQty = match.isNotEmpty
            ? int.parse(match['quantity'].toString())
            : 0;
      }

      if (availableQty < requestedQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${item['productName']} is out of stock. '
                    'Only $availableQty available, you ordered $requestedQty.'),
          ),
        );
        return;
      }
      }

    // Get seller info
    String sellerId = '';
    String sellerPhone = '';
    if (firstProdId != null) {
      final prod = await FirebaseFirestore.instance
          .collection('products')
          .doc(firstProdId)
          .get();
      sellerId = prod.data()?['companyId'] as String? ?? '';
      if (sellerId.isNotEmpty) {
        final sellerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(sellerId)
            .get();
        sellerPhone = sellerDoc.data()?['phoneNumber']?.toString() ?? '';
      }
    }

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Order data
    final orderData = {
      'orderId': orderId,
      'storeName': storeName,
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'status': 'Pending',
      'userId': uid,
      'username': userName,
      'userFullName': userStoreName,
      'userPhoneNumber': userPhone,
      'sellerId': sellerId,
      'sellerPhoneNumber': sellerPhone,
      'items': items,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await userOrdersRef.doc(orderId).set(orderData);

    // Write to sellers orders
    if (sellerId.isNotEmpty) {
      final sellerOrdersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .collection('orders');
      try {
        await sellerOrdersRef.doc(orderId).set(orderData);
      } catch (_) {}
    }

    // Clear cart
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in cartSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmed')),
    );

    // Navigate to OrdersPageUser
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrdersPageUser()),
    );
  } on FirebaseException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not confirm order: ${e.message}')),
    );
  }
}
