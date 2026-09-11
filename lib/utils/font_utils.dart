import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class FontUtils {
  /// Check if current language is Arabic
  static bool get isArabic => appStore.selectedLanguageCode == 'ar';

  /// Get the main font family (Cairo for all text)
  static String getMainFontFamily() {
    return 'Cairo';
  }

  /// Get the heading font family (Cairo)
  static String getHeadingFontFamily() {
    return 'Cairo';
  }

  /// Get TextTheme with Cairo font family
  static TextTheme getTextTheme({required bool isDark}) {
    Color textColor = isDark ? Colors.white : const Color(0xFF0A1626);
    return GoogleFonts.cairoTextTheme(TextTheme(
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.w800),
      displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor.withOpacity(0.7)),
    ));
  }

  /// Get heading text style (Cairo)
  static TextStyle getHeadingStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.cairo(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  /// Get body text style (Cairo)
  static TextStyle getBodyStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.cairo(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Get button text style (Cairo)
  static TextStyle getButtonStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.cairo(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  /// Get Google Fonts TextTheme
  static TextTheme getGoogleFontsTextTheme({required bool isDark}) {
    return getTextTheme(isDark: isDark);
  }
}
