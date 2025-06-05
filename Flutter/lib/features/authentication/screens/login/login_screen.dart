import 'package:ai_test/data/repositories/constants/text_string.dart';
import 'package:flutter/material.dart';
import 'package:ai_test/data/repositories/constants/sizes.dart';
import '../../../../data/repositories/constants/image_strings.dart';
import 'login_footer_widget.dart';
import 'login_form_header_widget.dart';
import 'login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(defaultSize),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                LoginHeaderWidget(
                  size: size,
                  image: welcomeScreenImage,
                  title: loginTitle,
                  subTitle: loginSubTitle,
                ),
                const LoginForm(),
                const LoginFooterWidget(),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
