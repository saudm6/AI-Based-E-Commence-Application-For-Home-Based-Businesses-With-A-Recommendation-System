import 'dart:io';
import 'package:ai_test/features/authentication/screens/dashboard/dashboard_seller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import '../../controllers/upload_file_controller.dart';

class SellerOnboardingScreen extends StatelessWidget {
  const SellerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final FileUploadController fileUploadController = Get.put(FileUploadController());
    final ImagePicker picker = ImagePicker();

    // Chose image
    Future<void> _pickImage() async {
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        fileUploadController.selectedFile.value = File(picked.path);
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: screenHeight,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // Business cert button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Select Business Certificate"),
              ),

              // Display selected image
              Obx(() {
                final file = fileUploadController.selectedFile.value;
                if (file != null) {
                  return Image.file(
                    file,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                } else {
                  return const Text("No image selected");
                }
              }),

              // Upload file to Firebase
              ElevatedButton(
                style: ElevatedButtonThemeNew.darkElevatedButtonTheme.style,
                onPressed: () async {
                  final file = fileUploadController.selectedFile.value;
                  if (file == null) {
                    Get.snackbar("Error", "No image selected");
                    return;
                  }

                  final uid = FirebaseAuth.instance.currentUser!.uid;

                  // Get storeName from Firestore
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                  final String? storeName = doc.data()?['storeName'] as String?;

                  // Error state
                  if (storeName == null || storeName.isEmpty) {
                    Get.snackbar("Error", "Could not find your store name.");
                    return;
                  }

                  // Upload image in file
                  final url = await fileUploadController.pickAndUploadImage(
                    companyId: storeName,
                    folder: 'business_cert',
                    isAdmin: false,
                  );

                  // Upload result
                  if (url != null) {
                    Get.snackbar("Success", "Image uploaded!");
                    Get.offAll(() => const DashboardSeller());
                  } else {
                    Get.snackbar("Error", "Upload failed");
                  }
                },
                child: const Text("Upload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









