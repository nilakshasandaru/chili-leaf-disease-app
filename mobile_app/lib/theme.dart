import 'package:flutter/material.dart';

class AppColors {
  static const Color cyan = Color(0xFF00BCD4);
  static const Color cyanLight = Color(0xFF4DD0E1);
  static const Color cyanDark = Color(0xFF0097A7);
  static const Color mintBg = Color(0xFFE0F7F4);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBtn = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFF111111);
  static const Color textGrey = Color(0xFF757575);
  static const Color textLight = Color(0xFFAAAAAA);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color earlyStage = Color(0xFFE0F7F4);
  static const Color advancedStage = Color(0xFFFFEBEE);
  static const Color advancedText = Color(0xFFE53935);
  static const Color highSeverity = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF4CAF50);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.cyan,
        scaffoldBackgroundColor: AppColors.mintBg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.successGreen, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.successGreen, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cyan, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIconColor: AppColors.textLight,
        ),
      );
}
