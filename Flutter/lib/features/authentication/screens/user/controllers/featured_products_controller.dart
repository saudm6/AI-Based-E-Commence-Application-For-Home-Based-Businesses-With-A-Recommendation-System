import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FeaturedProductsController extends GetxController {
  final RxList<Map<String, dynamic>> featured = <Map<String, dynamic>>[].obs;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadFeatured();
  }

  // Load one product from each category
  Future<void> _loadFeatured() async {
    try {
      final catSnap = await _db.collection('product_categories').get();
      final categoryIds = catSnap.docs.map((d) => d.id).toList();

      final rnd = Random();
      final futures = categoryIds.map((cat) async {
        final prodSnap = await _db
            .collection('products')
            .where('categoryId', isEqualTo: cat)
            .get();
        if (prodSnap.docs.isEmpty) return null;
        final docs = prodSnap.docs;
        final pick = docs[rnd.nextInt(docs.length)].data();
        pick['categoryId'] = cat;
        return pick;
      });

      final picks = (await Future.wait(futures)).whereType<Map<String, dynamic>>().toList();
      featured.assignAll(picks);
    } catch (e) {
      print('Error: $e');
    }
  }
}
