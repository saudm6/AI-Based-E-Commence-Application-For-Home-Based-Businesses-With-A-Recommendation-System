import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCategoryModel {
  final String id;
  final String name;

  ProductCategoryModel({
    required this.id,
    required this.name,
  });

  factory ProductCategoryModel.fromSnap(
      DocumentSnapshot<Map<String, dynamic>> snap,
      ) {
    return ProductCategoryModel(
      id: snap.id,
      name: snap.id,
    );
  }
}
