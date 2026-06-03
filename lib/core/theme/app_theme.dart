import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AdminAppTheme {
  AdminAppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.primary,
          brightness: Brightness.light,
          surface: AdminColors.surface,
        ),
        scaffoldBackgroundColor: AdminColors.background,
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.surface,
          foregroundColor: AdminColors.textPrimary,
          elevation: 0,
          shadowColor: AdminColors.shadow,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: AdminColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AdminColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AdminColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AdminColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AdminColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AdminColors.textSecondary),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary),
          headlineMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary),
          headlineSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminColors.textPrimary),
          titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminColors.textPrimary),
          titleMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AdminColors.textPrimary),
          bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AdminColors.textSecondary),
          bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AdminColors.textHint),
        ),
      );
}
