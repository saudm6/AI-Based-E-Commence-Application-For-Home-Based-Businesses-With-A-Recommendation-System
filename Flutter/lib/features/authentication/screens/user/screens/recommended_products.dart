import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../data/repositories/product/product_detail_page.dart';
import '../../../models/product_model.dart';

class RecommendedProducts extends StatelessWidget {
  const RecommendedProducts({
    Key? key,
    required this.productId,
    this.cardWidth = 160,
    this.cardAspectRatio = 0.65,
  }) : super(key: key);

  final String productId;
  final double cardWidth;
  final double cardAspectRatio;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {

    Product _toProduct(Map<String, dynamic> data, String id) {
      return Product(
        id: id,
        name: data['productName'] as String? ?? '',
        description: data['description'] as String? ?? '',
        images: List<String>.from(data['productImages'] ?? []),
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
      );
    }

    // Read product recommendations
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _db.collection('products').doc(productId).get(),
      builder: (ctx, prodSnap) {
        if (prodSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prodSnap.hasError) {
          return const Center(child: Text('Error loading recommendations'));
        }
        if (!prodSnap.hasData || !prodSnap.data!.exists) {
          return const Text('Product not found');
        }

        final raw = prodSnap.data!.data()?['recommendations'] as List<dynamic>? ?? [];
        final ids = <String>[
          for (final e in raw)
            if (e is Map && e['id'] != null) e['id'] as String,
        ];
        if (ids.isEmpty) return const Text('No recommendations');

        // Fetch recommended products
        Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchAll() async {
          final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

          for (var i = 0; i < ids.length; i += 10) {
            final chunk = ids.sublist(i, (i + 10).clamp(0, ids.length));

            try {
              final snap = await _db
                  .collection('products')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();
              allDocs.addAll(snap.docs);
            } catch (e) {
              debugPrint('Error: $e');
            }
          }
          return allDocs;
        }

        // UI
        return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _fetchAll(),
          builder: (ctx, recSnap) {

            if (recSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (recSnap.hasError) {
              return const Center(child: Text('Error loading recommendations'));
            }
            if (recSnap.data == null || recSnap.data!.isEmpty) {
              return const Text('No recommendations found');
            }

            final byId = {for (final d in recSnap.data!) d.id: d.data()};
            final ordered = [
              for (final id in ids)
                if (byId[id] != null) byId[id]!
            ];

            final cardHeight = cardWidth / cardAspectRatio;

            // Display products horizontally
            return SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ordered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final p = ordered[i];
                  final imgs = p['productImages'] as List<dynamic>? ?? [];
                  final imgUrl = imgs.isNotEmpty ? imgs.first as String : '';
                  final name   = p['productName'] as String? ?? '';
                  final price  = (p['price'] as num?)?.toDouble() ?? 0.0;

                  // Product Detail Page
                  return GestureDetector(
                      onTap: () {
                    final model = _toProduct(p, ids[i]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: model),
                      ),
                    );
                  },

                  // Display image, name etc
                  child:  Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: imgUrl.isNotEmpty
                                ? Image.network(imgUrl, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OMR ${price.toStringAsFixed(3)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
