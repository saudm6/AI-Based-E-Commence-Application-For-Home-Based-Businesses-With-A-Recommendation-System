import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_category_model.dart';

class BusinessCategoryController extends GetxController {
  final categories = <BusinessCategoryModel>[].obs;
  final selectedCategory = Rx<BusinessCategoryModel?>(null);

  final _ref =
  FirebaseFirestore.instance.collection('product_categories');

  @override
  void onInit() {
    super.onInit();
    
    // Listen to changes in category
    _listenCategories();
  }

  // Business_categories snapshot
  void _listenCategories() {
    _ref.orderBy('name').snapshots().listen((query) {
      categories.value =
          query.docs.map((d) => BusinessCategoryModel.fromSnapshot(d)).toList();
    });
  }

  // Selecting category
  void pickCategory(BusinessCategoryModel cat) {
    selectedCategory.value = cat;
    Get.back(result: cat);
  }
}
