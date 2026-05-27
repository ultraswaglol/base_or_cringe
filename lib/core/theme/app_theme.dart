import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0F0F11);
  static const Color cardBg = Color(0xFF18181C);

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonRed = Color(0xFFFF073A);
  static const Color accentPurple = Color(0xFF9D00FF);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8E8E93);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: accentPurple,
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: neonGreen,
        surface: cardBg,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: textWhite,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: textWhite,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textGray,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C2C35), width: 2),
        ),
      ),
    );
  }
}
