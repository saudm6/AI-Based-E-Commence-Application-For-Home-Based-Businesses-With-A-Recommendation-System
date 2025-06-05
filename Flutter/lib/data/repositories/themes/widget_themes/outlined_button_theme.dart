import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class OutlinedButtonThemeNew {
  OutlinedButtonThemeNew._();

  // Light Theme
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style:OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(),
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor),
      padding: EdgeInsets.symmetric(vertical: buttonHeight),
  ),);

  // Dark Theme
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(),
    foregroundColor: whiteColor,
    backgroundColor: primaryColor,
    side: BorderSide(color: primaryColor),
    padding: EdgeInsets.symmetric(vertical: buttonHeight),)
  );
}