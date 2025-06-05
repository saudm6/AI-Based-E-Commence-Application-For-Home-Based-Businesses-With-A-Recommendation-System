import 'package:ai_test/features/authentication/screens/signup/signup_screen_admin.dart';
import 'package:ai_test/features/authentication/screens/signup/signup_screen_seller.dart';
import 'package:ai_test/features/authentication/screens/signup/signup_screen_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/constants/text_string.dart';
import '../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';

class SignupScreenMain extends StatelessWidget {
  const SignupScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    final formSize = MediaQuery.of(context).size;
    final double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // User
                SizedBox(
                  width: 350,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const SignupScreenUser()),
                    style: ElevatedButtonThemeNew.lightElevatedButtonTheme.style,
                    child: Text(signupUserText.toUpperCase()),
                  ),
                ),

                // Seller
                SizedBox(
                  width: 350,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const SignupScreenSeller()),
                    style: ElevatedButtonThemeNew.lightElevatedButtonTheme.style,
                    child: Text(signupSellerText.toUpperCase()),
                  ),
                ),

                // Admin
                SizedBox(
                  width: 350,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const SignupScreenAdmin()),
                    style: ElevatedButtonThemeNew.lightElevatedButtonTheme.style,
                    child: Text(signupAdminText.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

