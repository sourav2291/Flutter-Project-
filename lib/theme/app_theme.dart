// theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Madathil Solar brand colors
  static const Color deepGreen = Color(0xFF0B5E4D);
  static const Color primaryGreen = Color(0xFF1DB954);
  static const Color lightGreen = Color(0xFF7EE787);
  static const Color solarYellow = Color(0xFFFFD166);

  static const Color darkGreen = Color(0xFF063B32);
  static const Color teal = Color(0xFF087F73);

  static const Color backgroundLight = Color(0xFFF4FAF6);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF10251F);
  static const Color textLight = Color(0xFF6B7C75);

  static LinearGradient mainGradient = const LinearGradient(
    colors: [deepGreen, primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient solarGradient = const LinearGradient(
    colors: [deepGreen, teal, primaryGreen, solarYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: backgroundLight,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: solarYellow,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: textDark,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),

      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),

      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),

      bodyLarge: TextStyle(fontSize: 16, color: textDark),

      bodyMedium: TextStyle(fontSize: 14, color: textLight),
    ),
  );
}
