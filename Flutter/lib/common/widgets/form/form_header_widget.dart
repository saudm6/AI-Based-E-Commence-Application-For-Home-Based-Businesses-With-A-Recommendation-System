import 'package:ai_test/data/repositories/themes/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.crossAxisAlignment, required this.size,
  });

  // Header constructor
  final String image, title, subtitle;
  final Size size;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [

          // Display image
          Image(
            image: AssetImage(image),
            height: size.height * 0.1 ,
          ),

          // Display title text
          Text(
            title,
            style: TextThemeNew.lightTextTheme.titleLarge,
          ),

          // Display sub title text
          Text(
            subtitle,
            style: TextThemeNew.lightTextTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}