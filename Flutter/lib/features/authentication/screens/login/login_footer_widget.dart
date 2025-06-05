import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/constants/sizes.dart';
import '../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import '../welcome_screen/welcome_screen.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('OR'),

        SizedBox(height: formHeightNew,),

        SizedBox(

          // Sign up main screen
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.to(() => const WelcomeScreen()),
            style: ElevatedButtonThemeNew.lightElevatedButtonTheme.style,
            child: Text('Go Back'),
          ),
        )
      ],
    );
  }
}
