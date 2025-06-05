import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/role_based/role_based_home_widget.dart';

class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Go to RoleBasedHome screen
      Get.off(() => const RoleBasedHome());
    } on FirebaseAuthException catch (e) {

      // Exception errors
      throw Exception('Sign in error: ${e.message}');
    } catch (e) {

      // Other errors
      throw Exception('Sign in error: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}