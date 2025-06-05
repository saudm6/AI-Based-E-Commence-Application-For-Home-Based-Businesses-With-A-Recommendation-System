import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/controllers/business_category_controller.dart';

class BusinessCategorySelectionPage extends StatelessWidget {
  const BusinessCategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Get business controller
    final controller = Get.put(BusinessCategoryController());

    return Scaffold(
      appBar: AppBar(title: const Text('Select Business Category')),
      body: Obx(() {
        final cats = controller.categories;

        // No categorizes
        if (cats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display the categories
        return ListView.separated(
          itemCount: cats.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => ListTile(

            // Display image at start of tile
            leading: cats[i].imgUrl != null
                ? Image.network(cats[i].imgUrl!, width: 40, height: 40)
                : const Icon(Icons.category),
            title: Text(cats[i].name),
            onTap: () => controller.pickCategory(cats[i]),
          ),
        );
      }),
    );
  }
}
