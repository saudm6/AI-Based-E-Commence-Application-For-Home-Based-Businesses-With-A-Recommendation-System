import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadController extends GetxController {

  Rx<File?> selectedFile = Rx<File?>(null);

  // Pick and upload image
  Future<String?> pickAndUploadImage({
    required String companyId,
    required String folder,
    bool isAdmin = false,
  }) async {
    try {

      // Pick image
      final XFile? xfile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (xfile == null) {
        Get.snackbar(
          'No Image Selected',
          'Please choose an image to upload.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Convert to  file
      final File imageFile = File(xfile.path);

      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

      // Choose folder
      final baseRef = FirebaseStorage.instance.ref();
      Reference storageRef = isAdmin
          ? baseRef.child('admin').child(companyId)
          : baseRef.child('companies').child(companyId);

      storageRef = storageRef.child(folder).child(fileName);

      // Upload
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Feedback
      Get.snackbar(
        'Upload Successful',
        'Image uploaded',
        snackPosition: SnackPosition.BOTTOM,
      );
      return downloadUrl;
    } catch (e) {

      // Handle errors
      Get.snackbar(
        'Upload Failed',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}

