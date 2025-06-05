import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'fetch_store_info.dart';

Future<void> addToCart({
  required BuildContext context,
  required String productId,
  required String productName,
  required List<String> productImages,
  required double productPrice,
  required Color? selectedVariant,
})  async {
  final user = FirebaseAuth.instance.currentUser;

  // User is signed in
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in to use the cart')),
    );
    return;
  }
  final uid = user.uid;
  final storeInfo = await fetchStoreInfo(productId);
  final cid = storeInfo['id'];
  final storeName = storeInfo['name'] ?? '';

  // Create doc id with with variant color + product id
  final variantValue = selectedVariant != null
      ? '0x${selectedVariant
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .toUpperCase()}'
      : '';
  final cartDocId = '${productId}_$variantValue';
  final cartDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('cart')
      .doc(cartDocId);

  try {

    // Check if this product/variant already in the cart
    final snapshot = await cartDoc.get();

    // If it exists add quantity
    if (snapshot.exists) {
      await cartDoc.update({'quantity': FieldValue.increment(1)});
    } else {

      // Create new entry with 1 quantity
      await cartDoc.set({
        'productId': productId,
        'productName': productName,
        'storeName': storeName,
        'imageUrl': productImages.isNotEmpty
            ? productImages.first
            : '',
        'selectedColor': variantValue,
        'price': productPrice,
        'quantity': 1,
      });
    }

    // Show feedback if successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  } on FirebaseException catch (e) {

    // Firestore errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding to cart: ${e.message}')),
    );
  }
}