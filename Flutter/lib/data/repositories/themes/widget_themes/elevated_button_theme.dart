import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ElevatedButtonThemeNew {
  ElevatedButtonThemeNew._();

  // Light Theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(),
      foregroundColor: primaryColor,
      backgroundColor: whiteColor,
      side: BorderSide(color: primaryColor),
      padding: EdgeInsets.symmetric(vertical: buttonHeight),)
  );

  // Dark Theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(),
      foregroundColor: whiteColor,
      backgroundColor: primaryColor,
      side: BorderSide(color: primaryColor),
      padding: EdgeInsets.symmetric(vertical: buttonHeight),)
  );
}




