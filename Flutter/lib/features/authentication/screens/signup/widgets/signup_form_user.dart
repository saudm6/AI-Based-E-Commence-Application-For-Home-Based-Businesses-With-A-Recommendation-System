import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/repositories/constants/text_string.dart';
import '../../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import '../../../controllers/business_category_controller.dart';
import '../../../controllers/signup_controller.dart';
import '../bindings/signup_binding.dart';

class SignupFormUser extends StatefulWidget {
  const SignupFormUser({super.key});

  @override
  State<SignupFormUser> createState() => _SignupFormUserState();
}

class _SignupFormUserState extends State<SignupFormUser> {
  final GlobalKey<SignUpFormWidgetState> _signUpFormKey =
      GlobalKey<SignUpFormWidgetState>();

  @override
  void initState() {
    super.initState();
    SignUpBinding().dependencies();
    if (!Get.isRegistered<BusinessCategoryController>()) {
      Get.put(BusinessCategoryController());
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SignUpController signUpController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [

        // Form widget
        SignUpFormWidget(
            key: _signUpFormKey,
            onSubmit: () {
              final signUpController = Get.find<SignUpController>();
              signUpController.registerUser(
                role: 'user',
                email: signUpController.email.text.trim(),
                password: signUpController.password.text.trim(),
              );
            }),

        // Sign up
        SizedBox(
          width: 350,
          child: ElevatedButton(
            onPressed: () {
              bool valid = _signUpFormKey.currentState?.validateForm() ?? false;
              if (valid) {
                final signUpController = Get.find<SignUpController>();
                signUpController.registerUser(
                  role: 'user',
                  email: signUpController.email.text.trim(),
                  password: signUpController.password.text.trim(),
                );
              }
            },
            style: ElevatedButtonThemeNew.darkElevatedButtonTheme.style,
            child: Text(signupText.toUpperCase()),
          ),
        ),
        ]),
    );
  }
}
