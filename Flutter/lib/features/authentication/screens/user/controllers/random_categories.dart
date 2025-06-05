import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/category_product_page.dart';

class RandomCategories extends StatelessWidget {
  const RandomCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(

      // Fetch all categories
      future: FirebaseFirestore.instance
          .collection('product_categories')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Get random order
        final docs = snapshot.data!.docs.toList()..shuffle(Random());

        return SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => _CategoryTile(doc: docs[i]),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.doc});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  static const int _maxChars = 22;

  @override
  Widget build(BuildContext context) {
    final data  = doc.data();
    final name  = (data['name'] ?? '').toString();
    final thumb = data['thumbnailUrl'] as String?;

    final displayName =
    name.length > _maxChars ? '${name.substring(0, _maxChars - 3)}...' : name;

    const double tileWidth    = 100;
    const double imageSize    = 60;
    const double avatarRadius = 30;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CategoryProductsPage(categoryId: doc.id, categoryName: name),
        ),
      ),

      // Cart layout
      child: SizedBox(
        width: tileWidth,
        child: Card(
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (thumb != null && thumb.isNotEmpty)
                  Image.network(
                    thumb,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.broken_image, size: imageSize),
                  )
                else
                  CircleAvatar(
                    radius: avatarRadius,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}