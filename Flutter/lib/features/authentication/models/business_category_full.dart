import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessCategoryFull {
  final String categoryId;
  final String categoryImg;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessCategoryFull({
    required this.categoryId,
    required this.categoryImg,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create instance from map
  factory BusinessCategoryFull.fromMap(Map<String, dynamic> json) {
    Timestamp _toTs(dynamic v) => v as Timestamp;
    return BusinessCategoryFull(
      categoryId:   json['categoryId']   as String,
      categoryImg:  json['categoryImg']  as String,
      categoryName: json['categoryName'] as String,
      createdAt:    _toTs(json['createdAt']).toDate(),
      updatedAt:    _toTs(json['updatedAt']).toDate(),
    );
  }

  // Change to map for firestore
  Map<String, dynamic> toMap() => {
    'categoryId':   categoryId,
    'categoryImg':  categoryImg,
    'categoryName': categoryName,
    'createdAt':    Timestamp.fromDate(createdAt),
    'updatedAt':    Timestamp.fromDate(updatedAt),
  };
}
