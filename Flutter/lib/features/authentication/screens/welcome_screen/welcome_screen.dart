import 'package:ai_test/data/repositories/constants/image_strings.dart';
import 'package:ai_test/data/repositories/constants/sizes.dart';
import 'package:ai_test/data/repositories/constants/text_string.dart';
import 'package:ai_test/data/repositories/themes/widget_themes/elevated_button_theme.dart';
import 'package:ai_test/data/repositories/themes/widget_themes/outlined_button_theme.dart';
import 'package:ai_test/features/authentication/screens/signup/signup_screen_main.dart';
import '../login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(defaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image(image: AssetImage(welcomeScreenImage)),
            Column(
              children: [

                // Title
                Text(
                  welcomeTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),

                // Subtitle
                Text(
                  welcomeSubTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              children: [

                // Login button
                Expanded(
                    child: OutlinedButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  style: OutlinedButtonThemeNew.lightOutlinedButtonTheme.style,
                  child: Text(loginText),
                )),
                const SizedBox(width: 15.0),

                // Signup button
                Expanded(
                  child: ElevatedButton(
                      onPressed: () => Get.to(() => const SignupScreenMain()),
                      style: ElevatedButtonThemeNew.darkElevatedButtonTheme.style,
                      child: Text(signupText)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

