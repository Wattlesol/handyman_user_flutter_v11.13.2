import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class FontUtils {
  /// Check if current language is Arabic
  static bool get isArabic => appStore.selectedLanguageCode == 'ar';

  /// Get the main font family (Alexandria for all text)
  static String getMainFontFamily() {
    return 'Alexandria'; // Use Alexandria for all regular text
  }

  /// Get the heading font family (Gluten for headings and buttons, except Arabic)
  static String getHeadingFontFamily() {
    if (isArabic) {
      return 'Alexandria'; // Use Alexandria for Arabic headings
    }
    return 'Gluten'; // Use Gluten for non-Arabic headings and buttons
  }

  /// Get TextTheme with language-aware font families
  static TextTheme getTextTheme({required bool isDark}) {
    String mainFont = getMainFontFamily();
    String headingFont = getHeadingFontFamily();
    Color textColor = isDark ? Colors.white : Colors.black;

    return TextTheme(
      // Headings use Gluten (except Arabic uses Alexandria)
      headlineSmall: TextStyle(color: textColor, fontFamily: headingFont),
      headlineMedium: TextStyle(color: textColor, fontFamily: headingFont),
      headlineLarge: TextStyle(color: textColor, fontFamily: headingFont),

      // Display text uses Gluten (except Arabic uses Alexandria)
      displayLarge: TextStyle(color: textColor, fontFamily: headingFont),
      displayMedium: TextStyle(color: textColor, fontFamily: headingFont),
      displaySmall: TextStyle(color: textColor, fontFamily: headingFont),

      // Titles use Gluten (except Arabic uses Alexandria)
      titleLarge: TextStyle(color: textColor, fontFamily: headingFont),
      titleMedium: TextStyle(color: textColor, fontFamily: headingFont),
      titleSmall: TextStyle(color: textColor, fontFamily: headingFont),

      // Labels use Gluten for buttons (except Arabic uses Alexandria)
      labelLarge: TextStyle(color: textColor, fontFamily: headingFont),
      labelMedium: TextStyle(color: textColor, fontFamily: headingFont),
      labelSmall: TextStyle(color: textColor, fontFamily: headingFont),

      // Body text always uses Alexandria
      bodyMedium: TextStyle(color: textColor, fontFamily: mainFont),
      bodySmall: TextStyle(color: textColor, fontFamily: mainFont),
      bodyLarge: TextStyle(color: textColor, fontFamily: mainFont),
    );
  }

  /// Get heading text style (Gluten font, except Alexandria for Arabic)
  static TextStyle getHeadingStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily:
          getHeadingFontFamily(), // Alexandria for Arabic, Gluten for others
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get body text style (Alexandria font for all languages)
  static TextStyle getBodyStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: getMainFontFamily(), // Always Alexandria
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get button text style (Gluten font, except Alexandria for Arabic)
  static TextStyle getButtonStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily:
          getHeadingFontFamily(), // Alexandria for Arabic, Gluten for others
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  /// Get Google Fonts TextTheme as fallback (for compatibility)
  static TextTheme getGoogleFontsTextTheme({required bool isDark}) {
    Color textColor = isDark ? Colors.white : Colors.black;

    // Use Inter as fallback for unsupported languages
    return GoogleFonts.interTextTheme(TextTheme(
      headlineSmall: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      headlineLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
    ));
  }
}
