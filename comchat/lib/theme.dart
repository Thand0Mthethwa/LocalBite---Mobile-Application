import 'package:flutter/material.dart';

/// Centralized app colors and theme.
class AppColors {
  AppColors._();

  // Primary brand color (deep blue)
  static const Color primary = Colors.black;
  static const Color onPrimary = Colors.white;

  // Accent / secondary (teal)
  static const Color secondary = Color.fromARGB(255, 50, 50, 50);
  static const Color onSecondary = Colors.white;

  // Background / surfaces
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color onSurface = Color.fromARGB(255, 30, 30, 30); // neutral dark
  static const Color onBackground = Colors.black;

  // Muted text / disabled
  static const Color muted = Color.fromARGB(255, 100, 100, 100);

  // Custom feature colors
  static const Color headerGreen = Color.fromARGB(255, 40, 40, 40);
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      primary: Colors.black,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onBackground,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
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
