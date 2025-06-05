import 'package:ai_test/data/repositories/user/authentication_repository/exceptions/signup_email_password_failure.dart';
import 'package:ai_test/features/authentication/screens/welcome_screen/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../features/authentication/controllers/role_based_controller.dart';

// Handles authentication operations
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  // Make sure current user state is on server
  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => const WelcomeScreen())
        : Get.offAll(() => const RoleBasedController());
  }

  // Create user in Firebase Auth
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    }

    // Log errors
     on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailAndPasswordFailure();
      throw ex;
    }
  }
  // Logout
  Future<void> logout() async => _auth.signOut();
}
