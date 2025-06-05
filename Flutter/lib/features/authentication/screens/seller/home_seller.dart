import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../common/widgets/welcome_back_title.dart';
import '../signedin/seller/add_proudct_page.dart';

class HomeSeller extends StatelessWidget {
  const HomeSeller({super.key});

  @override
  Widget build(BuildContext context) {
    // Get num columns
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: welcomeBackTitle(context)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('companyId', isEqualTo: userId)
              .limit(30)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading products'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No products yet'));
            }

            // Display products in grid
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: docs.length,
              itemBuilder: (ctx, index) {
                final data = docs[index].data();


                final images =
                    (data['productImages'] as List<dynamic>?)?.cast<String>() ??
                        [];
                final firstImage = images.isNotEmpty
                    ? images[0]
                    : 'https://via.placeholder.com/150';

                return Card(
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Product image
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: firstImage,
                          fit: BoxFit.cover,
                          placeholder: (c, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (c, url, err) => const Icon(Icons.error),
                        ),
                      ),

                      // Product name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data['productName'] as String? ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Edit button
                      TextButton(
                        onPressed: () {
                          Get.to(
                              () => AddProductPage(productId: docs[index].id));
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // Add a new product
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Get.to(() => const AddProductPage());
        },
      ),
    );
  }
}
