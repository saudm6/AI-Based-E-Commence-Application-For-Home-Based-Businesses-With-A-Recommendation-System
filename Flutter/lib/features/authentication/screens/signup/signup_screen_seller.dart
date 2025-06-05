import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_seller_footer.dart';
import 'package:ai_test/features/authentication/screens/signup/widgets/signup_form_seller_widget.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/form/form_header_widget.dart';
import '../../../../data/repositories/constants/image_strings.dart';
import '../../../../data/repositories/constants/text_string.dart';


class SignupScreenSeller extends StatelessWidget {
  const SignupScreenSeller({super.key});

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
                SignupFormSellerWidget(),
                SignupFormSellerFooter()
              ],
            ),
        ),
        ),
    );
  }
}

