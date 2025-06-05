import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessCategoryModel {
  final String id;
  final String name;
  final String? imgUrl;

  BusinessCategoryModel({
    required this.id,
    required this.name,
    this.imgUrl,
  });

  factory BusinessCategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return BusinessCategoryModel(
      id: snap.id,
      name: data['name'] ?? '',
    );
  }

  // Update doc in firestore
  Map<String, dynamic> toJson() => {
    'name': name,
  };

  @override
  String toString() => name;
}
