import 'package:flutter/material.dart';

/// Centralized app colors and theme.
class AppColors {
  AppColors._();

  // Primary brand color (deep blue)
  static const Color primary = Color.fromARGB(255, 222, 226, 233);
  static const Color onPrimary = Colors.white;

  // Accent / secondary (teal)
  static const Color secondary = Color(0xFF00A896);
  static const Color onSecondary = Colors.white;

  // Background / surfaces
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1F2937); // neutral dark
  static const Color onBackground = Color(0xFF111827);

  // Muted text / disabled
  static const Color muted = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 8, 8, 8),
      primary: const Color.fromARGB(255, 28, 28, 29),
      secondary: const Color.fromARGB(255, 78, 211, 45),
      surface: AppColors.surface,
      onPrimary: const Color.fromARGB(255, 248, 245, 245),
      onSecondary: const Color.fromARGB(255, 29, 235, 115),
      onSurface: AppColors.onBackground,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color.fromARGB(255, 236, 222, 222),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 14, 124, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: const Color.fromARGB(255, 121, 132, 151),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        showUnselectedLabels: true,
      ),
      // Card styling is intentionally minimal; prefer default elevated card styles.
      textTheme: Typography.material2021().black.apply(
        bodyColor: AppColors.onBackground,
        displayColor: AppColors.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
