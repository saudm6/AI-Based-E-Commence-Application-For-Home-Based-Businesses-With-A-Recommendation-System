import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/product_category_model.dart';

class ProductCategoryController extends GetxController {
  final categories = <ProductCategoryModel>[].obs;
  final selected   = Rx<ProductCategoryModel?>(null);

  final loading = true.obs;
  final error   = Rxn<String>();
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = FirebaseFirestore.instance
        .collection('product_categories')
        .orderBy(FieldPath.documentId)
        .snapshots()
        .listen(
          (snap) {

        // Convert docs to models
        categories.value = snap.docs
            .map((d) => ProductCategoryModel.fromSnap(d))
            .toList();
        loading.value = false;
        error.value   = null;
      },

      // Handle errors
      onError: (e) {
        error.value   = e.toString();
        loading.value = false;
      },
    );

    // Timeout
    Future.delayed(const Duration(seconds: 10), () {
      if (loading.value) {
        error.value = 'Loading timed out';
        loading.value = false;
      }
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
