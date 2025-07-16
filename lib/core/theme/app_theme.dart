import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Colors exactly from Figma design
  static const Color primaryColor = Color(0xFFFACD02); // Yellow from Figma
  static const Color secondaryColor = Color(0xFF351D66); // Dark purple from Figma
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textDarkColor = Color(0xFF351D66); // Dark purple for text
  static const Color textLightColor = Color(0xFFFFFFFF);
  static const Color textMediumColor = Color(0xFF666666); // Medium gray
  static const Color greyColor = Color(0xFFE8E8E8);
  static const Color darkGreyColor = Color(0xFF9E9E9E);
  static const Color splashBackgroundColor = Color(0xFFFFFFFF); // White background

  // Figma specific colors
  static const Color brownTextColor = Color(0xFF693E28); // Brown text from Figma
  static const Color lightGreyTextColor = Color(0xFF999999); // Light grey text
}

class AppTheme {
  // Text styles matching Figma design
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w700, // Bold as per Figma
    fontSize: 32,
    color: AppColors.textDarkColor,
    letterSpacing: -0.01, // -1% as per Figma
    height: 1.5, // Line height 1.5em as per Figma
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w600, // Semi-bold as per Figma
    fontSize: 18,
    color: AppColors.textDarkColor,
    letterSpacing: -0.005, // -0.5% as per Figma
    height: 1.45, // Line height 1.45em as per Figma
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    color: AppColors.textDarkColor,
    height: 1.5, // Line height 1.5em
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w700, // Bold as per Figma
    fontSize: 18,
    color: AppColors.textLightColor,
    letterSpacing: -0.005, // -0.5% as per Figma
    height: 1.2, // Reduced line height for better button text fit
  );

  // Button styles matching Figma
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.secondaryColor, // Dark text on yellow button
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32), // Increased vertical padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    minimumSize: const Size(double.infinity, 56), // Ensure minimum height
    textStyle: const TextStyle(
      fontFamily: 'Lato',
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.secondaryColor,
      letterSpacing: -0.005,
      height: 1.2,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
          color: AppColors.primaryColor, width: 2), // 2px border as per Figma
    ),
    elevation: 0,
    textStyle: buttonTextStyle.copyWith(color: AppColors.primaryColor),
  );

  // Theme data
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.backgroundColor,
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle,
      displayMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      labelLarge: buttonTextStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      foregroundColor: AppColors.textDarkColor,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyColor.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
