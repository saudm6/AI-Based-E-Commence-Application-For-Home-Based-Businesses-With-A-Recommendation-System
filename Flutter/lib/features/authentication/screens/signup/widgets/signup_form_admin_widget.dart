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

class SignupFormAdminWidget extends StatefulWidget {
  const SignupFormAdminWidget({
    super.key,
  });

  @override
  State<SignupFormAdminWidget> createState() => _SignupFormAdminWidgetState();
}

class _SignupFormAdminWidgetState extends State<SignupFormAdminWidget> {
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
    final signUpController = Get.put(SignUpController());

    final FileUploadController fileUploadController =
        Get.put(FileUploadController());
    Get.put(BusinessCategoryController());
    final _formKey = GlobalKey<FormState>();
    final formSize = MediaQuery.of(context).size;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            // Sign up
            SignUpFormWidget(
              key: _signUpFormKey,
              onSubmit: () {
                final signUpController = Get.find<SignUpController>();
                signUpController.registerUser(
                  role: 'admin',
                  email: signUpController.email.text.trim(),
                  password: signUpController.password.text.trim(),
                );
              },
            ),
            SizedBox(height: formHeightNew),

            // File name
            Obx(() {
              if (fileUploadController.selectedFile.value != null) {
                final filePath = fileUploadController.selectedFile.value!.path;
                final fileName = filePath.split('/').last;
                return Text(
                  "Selected file: $fileName",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              } else {
                return const SizedBox();
              }
            }),

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
                      role: 'admin',
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
        ));
  }
}
