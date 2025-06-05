import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSubCategory {
  final String id;
  final String name;

  ProductSubCategory({required this.id, required this.name});

  factory ProductSubCategory.fromSnap(
      DocumentSnapshot<Map<String, dynamic>> snap) {

    // Retrieve map from snapshot
    final d = snap.data()!;
    return ProductSubCategory(id: snap.id, name: d['name'] ?? '');
  }
}
