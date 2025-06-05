import 'package:ai_test/data/repositories/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextThemeNew{
  TextThemeNew._();

  // Light Text Theme
  static TextTheme lightTextTheme = TextTheme(
    titleLarge: GoogleFonts.montserrat(
        fontSize: 28.0, fontWeight: FontWeight.bold, color: blackColor),
    displayLarge: GoogleFonts.montserrat(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: blackColor),
    bodyLarge: GoogleFonts.poppins(
        fontSize: 21.0, fontWeight: FontWeight.normal, color: blackColor),
    headlineMedium: GoogleFonts.poppins(
        fontSize: 16.0, fontWeight: FontWeight.w600, color: blackColor),
    displayMedium: GoogleFonts.poppins(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: blackColor),
    bodyMedium: GoogleFonts.poppins(
        fontSize: 13.5, fontWeight: FontWeight.normal, color: blackColor),
    displaySmall: GoogleFonts.poppins(
        fontSize: 9.5, fontWeight: FontWeight.normal, color: blackColor),
  );

  // Dark Text Theme
  static TextTheme darkTextTheme = TextTheme(
    titleLarge: GoogleFonts.montserrat(
        fontSize: 28.0, fontWeight: FontWeight.bold, color: whiteColor),
    displayLarge: GoogleFonts.montserrat(
        fontSize: 24.0, fontWeight: FontWeight.w700, color: whiteColor),
    bodyLarge: GoogleFonts.poppins(
        fontSize: 24.0, fontWeight: FontWeight.w700, color: whiteColor),
    headlineMedium: GoogleFonts.poppins(
        fontSize: 16.0, fontWeight: FontWeight.w600, color: whiteColor),
    displayMedium: GoogleFonts.poppins(
        fontSize: 14.0, fontWeight: FontWeight.w600, color: whiteColor),
    bodyMedium: GoogleFonts.poppins(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: whiteColor),
    displaySmall: GoogleFonts.poppins(
        fontSize: 9.5, fontWeight: FontWeight.normal, color: whiteColor),
    headlineSmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.normal, color: whiteColor)
  );
}