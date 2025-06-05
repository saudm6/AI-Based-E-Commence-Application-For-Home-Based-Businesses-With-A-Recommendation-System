import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/repositories/constants/sizes.dart';
import '../../../../../data/repositories/constants/text_string.dart';
import '../../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import 'package:ai_test/features/authentication/controllers/upload_file_controller.dart';
import '../../../controllers/business_category_controller.dart';
import '../../../controllers/signup_controller.dart';
import '../bindings/signup_binding.dart';
import 'business_category_selector_widget.dart';

class SignupFormSellerWidget extends StatefulWidget {
  const SignupFormSellerWidget({super.key});

  @override
  State<SignupFormSellerWidget> createState() => _SignupFormSellerWidgetState();
}

class _SignupFormSellerWidgetState extends State<SignupFormSellerWidget> {
  final GlobalKey<SignUpFormWidgetState> _signUpFormKey =
      GlobalKey<SignUpFormWidgetState>();
  late final SignUpController signUpController;

  @override
  void initState() {
    super.initState();
    SignUpBinding().dependencies();

    if (!Get.isRegistered<BusinessCategoryController>()) {
      Get.put(BusinessCategoryController());
    }
    signUpController = Get.find<SignUpController>();
  }

  @override
  Widget build(BuildContext context) {
    final FileUploadController fileUploadController =
        Get.put(FileUploadController());
    Get.put(BusinessCategoryController());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [

          // Sign Up Form Widget
          SignUpFormWidget(
            key: _signUpFormKey,
            onSubmit: () {
              final signUpController = Get.find<SignUpController>();
              signUpController.registerUser(
                role: 'seller',
                email: signUpController.email.text.trim(),
                password: signUpController.password.text.trim(),
              );
            },
          ),

          // Category Selector Widget
          const BusinessCategorySelectorWidget(),
          SizedBox(height: formHeightNew),

          // Sign up button
          SizedBox(
            width: 350,
            child: ElevatedButton(
              onPressed: () {
                bool valid =
                    _signUpFormKey.currentState?.validateForm() ?? false;
                if (valid) {
                  final signUpController = Get.find<SignUpController>();
                  signUpController.registerUser(
                    role: 'seller',
                    email: signUpController.email.text.trim(),
                    password: signUpController.password.text.trim(),
                  );
                }
              },
              style: ElevatedButtonThemeNew.darkElevatedButtonTheme.style,
              child: Text(nextText.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }
}
