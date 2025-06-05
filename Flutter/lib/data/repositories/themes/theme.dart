import 'package:ai_test/data/repositories/themes/widget_themes/outlined_button_theme.dart';
import 'package:ai_test/data/repositories/themes/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:ai_test/data/repositories/themes/widget_themes/elevated_button_theme.dart';

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      textTheme: TextThemeNew.lightTextTheme,
      outlinedButtonTheme: OutlinedButtonThemeNew.lightOutlinedButtonTheme,
      elevatedButtonTheme: ElevatedButtonThemeNew.lightElevatedButtonTheme,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      textTheme: TextThemeNew.darkTextTheme,
      outlinedButtonTheme: OutlinedButtonThemeNew.darkOutlinedButtonTheme,
      elevatedButtonTheme: ElevatedButtonThemeNew.darkElevatedButtonTheme,

  );
}
