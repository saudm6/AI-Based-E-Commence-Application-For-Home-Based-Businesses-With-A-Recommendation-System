import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_test/features/authentication/controllers/business_category_controller.dart';
import '../../../../../common/widgets/form/business_category_selection_page.dart';

class BusinessCategorySelectorWidget extends StatelessWidget {
  const BusinessCategorySelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final BusinessCategoryController categoryController = Get.find<BusinessCategoryController>();

    return GestureDetector(
      onTap: () async {

        // Go to  category selection page
        final selectedCategory = await Get.to(() => const BusinessCategorySelectionPage());
        if (selectedCategory != null) {

          categoryController.selectedCategory.value = selectedCategory;
        }
      },
      child: Obx(() {

        // Display updated category
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              categoryController.selectedCategory.value?.name ??
                  'Select business category',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }
}
