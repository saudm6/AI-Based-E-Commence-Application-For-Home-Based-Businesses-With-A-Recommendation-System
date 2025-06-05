import 'package:ai_test/common/widgets/form/form_header_widget.dart';
import 'package:ai_test/data/repositories/constants/image_strings.dart';
import 'package:ai_test/data/repositories/constants/text_string.dart';
import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_footer.dart';
import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_user.dart';
import 'package:flutter/material.dart';

class SignupScreenUser extends StatelessWidget {
  const SignupScreenUser({super.key});

  @override
  Widget build(BuildContext context) {
    final formSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              FormHeaderWidget(
                  image: splashLogo,
                  title: signUpTitleUser,
                  subtitle: signUpSubTitleUser, size: formSize,),
              SignupFormUser(),
              SignUpFormFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
