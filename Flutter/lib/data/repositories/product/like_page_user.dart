import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_test/data/repositories/product/product_detail_page.dart';
import '../../../features/authentication/models/product_model.dart';

// Displays all products user liked
class LikesPageUser extends StatefulWidget {
  const LikesPageUser({super.key});

  @override
  _LikesPageUserState createState() => _LikesPageUserState();
}

class _LikesPageUserState extends State<LikesPageUser> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Tell user to sign in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Likes')),
        body: const Center(child: Text('Sign in to view your likes')),
      );
    }

    // Likes sub collection for the user
    final likesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('likes');

    return Scaffold(
      appBar: AppBar(title: const Text('Your Likes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

        // Updates what user liked in real time
        stream: likesRef.snapshots(),
        builder: (context, snapshot) {

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract document
          final docs = snapshot.data!.docs;

          // Empty state
          if (docs.isEmpty) {
            return const Center(child: Text('You dont have any likes yet'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {

              // Retrieve fields from the like document
              final docData = docs[index].data();
              final productId   = docs[index].id;
              final productTitle = docData['productTitle'] as String? ?? 'No title';
              final storeName    = docData['storeName']    as String? ?? 'Unknown store';
              final price        = (docData['price'] as num?)?.toDouble() ?? 0.0;
              final priceText    = 'OMR ${price.toStringAsFixed(3)}';

              return ListTile(

                // Display liked products
                title: Text(productTitle),
                subtitle: Text(storeName),
                trailing: Text(
                  priceText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {

                  // Fetch the product document
                  final prodSnap = await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .get();
                  if (!prodSnap.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product no longer exists')),
                    );
                    return;
                  }

                  // Define document fields
                  final prodData = prodSnap.data()!;
                  final name = prodData['productName'] as String? ?? productTitle;
                  final description = prodData['productDescription'] as String? ?? '';
                  final images = (prodData['productImages'] as List<dynamic>?)
                      ?.cast<String>() ??
                      [];
                  final priceVal = (prodData['price'] as num?)?.toDouble() ?? price;

                  //  Build your Product model
                  final product = Product(
                    id: productId,
                    name: name,
                    description: description,
                    images: images,
                    price: priceVal,
                  );

                  // Redirect to the product detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
