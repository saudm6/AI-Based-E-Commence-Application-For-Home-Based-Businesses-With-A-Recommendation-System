import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/constants/sizes.dart';
import '../../../../data/repositories/constants/text_string.dart';
import '../../../../data/repositories/themes/widget_themes/elevated_button_theme.dart';
import '../../controllers/signin_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    final signInController = Get.put(SignInController());
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                TextFormField(
                  controller: signInController.emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_outlined),
                    labelText: emailText,
                    hintText: emailPlaceholder,
                  ),
                ),

                SizedBox(height: formHeightNew),

                // Password
                TextFormField(
                  controller: signInController.passwordController,
                  obscureText: _passwordVisible,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      labelText: passwordText,
                      hintText: passwordText,
                      suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            // Toggle password visibility
                            setState(() {
                              _passwordVisible != _passwordVisible;
                            });
                          })),
                ),

                SizedBox(height: formHeightNew),

                // Login button
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await signInController.signInWithEmailAndPassword(
                              email:
                                  signInController.emailController.text.trim(),
                              password: signInController.passwordController.text
                                  .trim(),
                            );
                          }
                        },
                        style: ElevatedButtonThemeNew
                            .darkElevatedButtonTheme.style,
                        child: const Text(loginText)))
              ],
            ),
          ),
        ));
  }
}
