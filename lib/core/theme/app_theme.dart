import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF4A90E2);
  static const onPrimary = Colors.white;

  // Status Colors
  static const error = Colors.red;
  static const success = Colors.green;
  static const warning = Colors.orange;
  static const info = Colors.blue;

  // Text Colors
  static const textPrimary = Colors.black;
  static const textSecondary = Colors.grey;
  static const textLight = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Background Colors
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF3F4F6);

  // Border & Divider Colors
  static const border = Color(0xFFE0E0E0);
  static const borderLight = Color(0xFFF3F4F6);
  static const divider = Color(0xFFE5E7EB);

  // Input Colors
  static const textFieldFill = Color(0xFFF5F6FA);
  static const inputBorder = Color(0xFFD1D5DB);

  // Shadow Colors
  static const shadowLight = Color(0x0A000000);
  static const shadowMedium = Color(0x1A000000);
  static const shadowDark = Color(0x33000000);

  // Brand Colors (from your existing design)
  static const brandGreen = Color(0xFF2E5233);
  static const brandBlue = Color(0xFF4A90E2);
  static const brandPurple = Color(0xFF9B59B6);

  // Utility Colors
  static const transparent = Colors.transparent;
  static const overlay = Color(0x80000000);

  // Grey Scale
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  static const profileGradientStart = Color(0xFFE8A87C);
  static const profileGradientEnd = Color(0xFFC27D5C);
  static const grey = grey400;
  static const blueGrey = Color(0xFF607D8B);
}

ThemeData get appLightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.onPrimary,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.textFieldFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);
