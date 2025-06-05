import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/product/product_detail_page.dart';
import '../authentication/models/product_model.dart';

// Detailed info about store + products
class StoreDetailsPage extends StatefulWidget {
  final String sellerId;
  final String storeName;

  const StoreDetailsPage({super.key, required this.sellerId, required this.storeName});

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _sellerFuture;

  @override
  void initState() {
    super.initState();

    // Get seller info
    _sellerFuture = FirebaseFirestore.instance.collection('users').doc(widget.sellerId).get();
  }

  // Open Google Maps at store location
  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open Google Maps.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header: store details + logo
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _sellerFuture,
            builder: (context, snap) {

              // Loading state
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Error or missing info
              if (!snap.hasData || !snap.data!.exists) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Store information not found'),
                );
              }

              // Fields that will be used
              final data = snap.data!.data()!;
              final categoryMap = data['businessCategory'] as Map<String, dynamic>?;
              final categoryName = categoryMap?['categoryName'] as String? ?? 'N/A';
              final phone = data['phoneNumber']?.toString() ?? 'N/A';
              final geo = data['storeLocation'] as GeoPoint?;
              final logoUrl = data['companyImageUrl'] as String?;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Company logo
                    Center(
                      child: logoUrl != null
                          ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(logoUrl),
                      )
                          : const CircleAvatar(
                        radius: 48,
                        child: Icon(Icons.store, size: 48),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Store name
                    Text(widget.storeName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),

                    // Business category
                    Text('Category: $categoryName'),
                    const SizedBox(height: 4),

                    // Phone Number
                    Text('Phone: $phone'),
                    const SizedBox(height: 8),

                    // View store location button
                    if (geo != null)
                      ElevatedButton(
                        onPressed: () => _openMaps(geo.latitude, geo.longitude),
                        child: const Text('View store location'),
                      ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // Products list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

              // Listen for product updates from the seller
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('companyId', isEqualTo: widget.sellerId)
                  .snapshots(),
              builder: (context, snap) {

                // Loading state
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // No products found
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found for this store'));
                }
                final docs = snap.data!.docs;

                // Build products
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final id = docs[index].id;
                    final name = data['productName'] as String? ?? '';
                    final description = data['productDescription'] as String? ?? '';
                    final images = (data['productImages'] as List<dynamic>?)?.cast<String>() ?? [];
                    final priceValue = (data['price'] as num?)?.toDouble() ?? 0.0;
                    final priceText = 'OMR ${priceValue.toStringAsFixed(3)}';

                    return ListTile(

                      // Placeholder image
                      leading: images.isNotEmpty
                          ? Image.network(images.first, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text(name),
                      subtitle: Text(priceText),
                      onTap: () {

                        // Build product model
                        final product = Product(
                          id: id,
                          name: name,
                          description: description,
                          images: images,
                          price: priceValue,
                        );

                        // Go to product detail page
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
          ),
        ],
      ),
    );
  }
}