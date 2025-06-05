import 'dart:io';
import 'package:ai_test/data/repositories/user/authentication_repository/authentication_repository.dart';
import 'package:ai_test/features/authentication/screens/user/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/onboarding/admin_onboarding_screen.dart';
import '../screens/onboarding/seller_onboarding_screen.dart';
import 'business_category_controller.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNumber = TextEditingController();
  final BusinessCategoryController categoryController = Get.find<BusinessCategoryController>();

  Rx<File?> certificateFile = Rx<File?>(null);

  Future<void> registerUser({
    required String role,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await AuthenticationRepository.instance
          .createUserWithEmailAndPassword(email, password);

      final String companyId = FirebaseAuth.instance.currentUser!.uid;
      final String uid = userCredential.user!.uid;
      final selectedCategory = categoryController.selectedCategory.value;


      // User data
      await FirebaseFirestore.instance.collection('users').doc(companyId).set({
        'companyId': companyId,
        'role': role,
        'email': email,
        'storeName': fullName.text,
        'phoneNumber': int.tryParse(phoneNumber.text) ?? 'No Number was inputted',
        'certificateUrl': null,
        'businessCategory': selectedCategory?.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Go to screen
      if (role == 'seller') {
        Get.offAll(() => const SellerOnboardingScreen());
      } else if (role == 'admin') {
        Get.offAll(() => const AdminOnboardingScreen());
      } else {
        Get.offAll(() => const UserDashboard());
      }
    } catch (e) {
      // Error state
      print('Error: $e');
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    fullName.dispose();
    phoneNumber.dispose();
    super.onClose();
  }
}


