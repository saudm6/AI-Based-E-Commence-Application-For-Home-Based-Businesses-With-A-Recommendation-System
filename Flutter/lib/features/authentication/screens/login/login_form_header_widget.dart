import 'package:flutter/material.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({
    super.key,
    required this.size,
    this.imageColor,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final Size size;
  final Color? imageColor;
  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // Image
        Image(
          image: AssetImage(image),
          height: size.height * 0.1,
        ),

        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        // Subtitle
        Text(
          subTitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
