import 'package:flutter/material.dart';

/// Centralized app colors and theme.
class AppColors {
  AppColors._();

  // Primary brand color (deep blue)
  static const Color primary = Color(0xFF0B3D91);
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
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
      onBackground: AppColors.onBackground,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
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
