import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../data/repositories/constants/sizes.dart';
import '../../../../../data/repositories/constants/text_string.dart';
import '../../../controllers/business_category_controller.dart';
import '../../../controllers/signup_controller.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key, required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  State<SignUpFormWidget> createState() => SignUpFormWidgetState();
}

class SignUpFormWidgetState extends State<SignUpFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SignUpController signUpController;

  @override
  void initState() {
    super.initState();
    signUpController = Get.find<SignUpController>();
    if (!Get.isRegistered<BusinessCategoryController>()) {
      Get.put(BusinessCategoryController());
    }
    Get.put<BusinessCategoryController>(BusinessCategoryController());

  }

  // Validate form
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(formHeightNew),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Store Name
              TextFormField(
                controller: signUpController.fullName,
                decoration: const InputDecoration(
                  labelText: fullNameNew,
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  hintText: fullNamePlaceholder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter name of the store";
                  }
                  return null;
                },
              ),

              SizedBox(height: formHeightNew),


              // Email Field
              TextFormField(
                controller: signUpController.email,
                decoration: const InputDecoration(
                  labelText: emailText,
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: emailPlaceholder,
                ),
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }

                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!emailRegex.hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),


              SizedBox(height: formHeightNew),


              // Phone Number Field
              TextFormField(
                keyboardType: TextInputType.number,
                controller: signUpController.phoneNumber,
                decoration: const InputDecoration(
                  labelText: phoneNumberInput,
                  prefixIcon: Icon(Icons.numbers),
                  hintText: phoneNumberPlaceholder,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  return null;
                },
              ),
              SizedBox(height: formHeightNew),

              // Password Field
              TextFormField(
                controller: signUpController.password,
                obscureText: _passwordVisible,
                decoration: InputDecoration(
                  labelText: passwordText,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  hintText: passwordText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
