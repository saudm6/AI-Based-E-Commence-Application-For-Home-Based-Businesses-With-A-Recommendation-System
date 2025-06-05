import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/repositories/constants/sizes.dart';
import '../../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import '../../welcome_screen/welcome_screen.dart';

class SignupFormSellerFooter extends StatelessWidget {
  const SignupFormSellerFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(defaultSize),

              // Sign up main screen
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const WelcomeScreen()),
                  style: ElevatedButtonThemeNew.lightElevatedButtonTheme.style,
                  child: Text('Go Back'),
                ),
              )),
        ],
      ),
    );
  }
}