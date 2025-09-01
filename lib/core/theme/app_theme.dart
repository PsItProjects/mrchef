import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryColor = Color(0xFFFACD02); // Yellow from Figma
  static const Color secondaryColor = Color(0xFF351D66); // Dark purple from Figma

  // Background colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF7F7FB); // Light gray surface
  static const Color searchBackgroundColor = Color(0xFFFFFAE6); // Light yellow background
  static const Color cardBackgroundColor = Color(0xFFF1F6F9); // Card background

  // Text colors
  static const Color textDarkColor = Color(0xFF351D66); // Dark purple for text
  static const Color textLightColor = Color(0xFFFFFFFF);
  static const Color textMediumColor = Color(0xFF666666); // Medium gray
  static const Color textSecondaryColor = Color(0xFF5E5E5E); // Search text gray
  static const Color brownTextColor = Color(0xFF693E28); // Brown text from Figma
  static const Color searchIconColor = Color(0xFF592E2C); // Brown color for search icon
  static const Color lightGreyTextColor = Color(0xFF999999); // Light grey text
  static const Color darkTextColor = Color(0xFF262626); // Dark text
  static const Color priceTextColor = Color(0xFF1A2023); // Price text
  static const Color optionTextColor = Color(0xFF727272); // Option text

  // Gray scale
  static const Color greyColor = Color(0xFFE8E8E8);
  static const Color darkGreyColor = Color(0xFF9E9E9E);
  static const Color lightGreyColor = Color(0xFFF7F7FB);

  // Status colors
  static const Color successColor = Color(0xFF27AE60); // Green
  static const Color errorColor = Color(0xFFEB5757); // Red
  static const Color warningColor = Color(0xFFFACD02); // Yellow (same as primary)

  // Kitchen card gradient colors
  static const Color kitchenGradientStart = Color(0xFFA44502);
  static const Color kitchenGradientEnd = Color(0xFF8F3A02);

  // Shadow colors
  static const Color shadowColor = Color(0xFF2D5F8B);
  static const Color blackShadowColor = Color(0xFF000000);

  // Button colors
  static const Color favoriteButtonColor = Color(0xFFFCE167); // Yellow background for favorite
  static const Color addButtonShadowColor = Color(0xFF974968);

  // Transparent
  static const Color transparent = Color(0x00000000);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2D2D2D);
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFFB3B3B3);
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

  // Additional text styles
  static const TextStyle searchTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textSecondaryColor,
  );

  static const TextStyle smallButtonTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w700,
    fontSize: 10,
    color: AppColors.searchIconColor,
  );

  static const TextStyle priceTextStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.priceTextColor,
  );

  static const TextStyle statusTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle tabTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
  );

  static const TextStyle optionTextStyle = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.optionTextColor,
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

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.backgroundColor,
      background: AppColors.backgroundColor,
      error: AppColors.errorColor,
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle,
      displayMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: searchTextStyle,
      labelLarge: buttonTextStyle,
      labelMedium: smallButtonTextStyle,
      labelSmall: optionTextStyle,
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
      surfaceTintColor: AppColors.transparent,
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
    cardTheme: CardTheme(
      color: AppColors.backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.darkSurfaceColor,
      background: AppColors.darkBackgroundColor,
      error: AppColors.errorColor,
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: AppColors.darkTextPrimaryColor),
      displayMedium: subheadingStyle.copyWith(color: AppColors.darkTextPrimaryColor),
      bodyLarge: bodyStyle.copyWith(color: AppColors.darkTextPrimaryColor),
      bodyMedium: searchTextStyle.copyWith(color: AppColors.darkTextSecondaryColor),
      labelLarge: buttonTextStyle,
      labelMedium: smallButtonTextStyle,
      labelSmall: optionTextStyle.copyWith(color: AppColors.darkTextSecondaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackgroundColor,
      foregroundColor: AppColors.darkTextPrimaryColor,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: AppColors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceColor,
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
    cardTheme: CardTheme(
      color: AppColors.darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
