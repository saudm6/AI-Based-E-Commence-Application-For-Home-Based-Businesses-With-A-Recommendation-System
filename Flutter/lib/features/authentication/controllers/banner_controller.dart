import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BannerController extends GetxController{
  RxList<String> bannerUrls = RxList<String>([]);

  @override
  void onInit() {
    super.onInit();
    fetchBannersUrls();
  }

  // Get banners docs
  Future<void> fetchBannersUrls()async {
    try{
      // Query banners collection
      QuerySnapshot bannerSnapshot = await FirebaseFirestore.instance.collection('new_banners').get();

      // Map each imageUrl field
      if (bannerSnapshot.docs.isNotEmpty) {
        bannerUrls.value = bannerSnapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();
      }
    } catch(e){

      // Log errors
      print('Error: $e' );
    }
  }
}