import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import '../../../models/business_category_full.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {

    // Get docs
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('business_categories')
          .get(),
      builder: (context, snapshot) {

        // Error state
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: Get.height / 5,
            child: const Center(child: CupertinoActivityIndicator()),
          );
        }

        // Empty state
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No category found!'));
        }


        // Display categories
        return SizedBox(
          height: Get.height / 6.65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final raw = docs[index].data() as Map<String, dynamic>;
              final String catId   = raw['categoryId']   as String? ?? '';
              final String img     = raw['categoryImg']  as String? ?? '';
              final String name    = raw['categoryName'] as String? ?? '';
              final tsCreated      = raw['createdAt']    as Timestamp?;
              final tsUpdated      = raw['updatedAt']    as Timestamp?;
              final DateTime createdAt = tsCreated != null
                  ? tsCreated.toDate()
                  : DateTime.now();
              final DateTime updatedAt = tsUpdated != null
                  ? tsUpdated.toDate()
                  : DateTime.now();

              final cat = BusinessCategoryFull(
                categoryId:   catId,
                categoryImg:  img,
                categoryName: name,
                createdAt:    createdAt,
                updatedAt:    updatedAt,
              );

              // Build category card
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: FillImageCard(
                  borderRadius: 20.0,
                  width: Get.width / 4.0,
                  heightImage: Get.height / 12,
                  imageProvider: CachedNetworkImageProvider(cat.categoryImg),
                  title: Center(
                    child: Text(
                      cat.categoryName,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
