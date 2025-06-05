import 'package:cloud_firestore/cloud_firestore.dart';

// Fetches companyId and storeName
Future<Map<String, String?>> fetchStoreInfo(String productId) async {
  final prodSnap = await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .get();
  final data = prodSnap.data();
  final cid = data?['companyId'] as String?;

  // If company id exists get company info
  if (cid != null) {
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(cid)
        .get();
    final storeName = userSnap.data()?['storeName'] as String?;
    return {'id': cid, 'name': storeName};
  }

  // If no company id is found
  return {'id': null, 'name': null};
}
