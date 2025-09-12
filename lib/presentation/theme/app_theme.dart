import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: const CardTheme(
        elevation: AppDimensions.cardElevation,
        color: AppColors.cardBackground,
        margin: EdgeInsets.all(AppDimensions.paddingSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          elevation: 2,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          side: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.dark,
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange,
        surface: AppColors.grey800,
        background: AppColors.grey900,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
        onError: AppColors.white,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: AppDimensions.appBarElevation,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: const CardTheme(
        elevation: AppDimensions.cardElevation,
        color: AppColors.grey800,
        margin: EdgeInsets.all(AppDimensions.paddingSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
      ),
    );
  }
}