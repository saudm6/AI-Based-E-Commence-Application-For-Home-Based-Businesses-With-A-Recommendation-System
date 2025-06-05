import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/controllers/product_category_controller.dart';
import '../../../features/authentication/models/product_category_model.dart';

// Displays product categories
class ProductCategorySelectionPage extends StatelessWidget {
  const ProductCategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {

    final c = Get.find<ProductCategoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Product Category')),
      body: Obx(() {

        // Error state
        if (c.error.value != null) {
          return Center(
            child: Text(
              'Error loading categories:${c.error.value}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        // Loading state
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty state
        if (c.categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        // Successful state
        return ListView.separated(
          itemCount: c.categories.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.category),
            title: Text(c.categories[i].name),
            onTap: () {

              // Return selected category
              Get.back<ProductCategoryModel>(result: c.categories[i]);
            },
          ),
        );
      }),
    );
  }
}
