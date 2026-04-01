import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shape.dart';
import 'app_typography.dart';

/// AiCar 디자인 시스템 테마
/// 라이트 모드 전용
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // ── Color Scheme ──────────────────────────────
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.textOnDark,
          onSecondary: AppColors.textOnDark,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textOnDark,
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ── Text Theme ────────────────────────────────
        textTheme: TextTheme(
          displayLarge: AppTypography.display4xl,
          displayMedium: AppTypography.display3xl,
          headlineLarge: AppTypography.heading2xl,
          headlineMedium: AppTypography.headingXl,
          bodyLarge: AppTypography.bodyLg,
          bodyMedium: AppTypography.bodyMd,
          bodySmall: AppTypography.bodySm,
          labelLarge: AppTypography.captionXs,
          labelSmall: AppTypography.overline2xs,
        ),

        // ── AppBar ────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),

        // ── Elevated Button ───────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonSolidDefault,
            foregroundColor: AppColors.textOnDark,
            disabledBackgroundColor: AppColors.buttonSolidDisabled,
            disabledForegroundColor: AppColors.textDisabled,
            shape: const RoundedRectangleBorder(
              borderRadius: AppShape.radiusMd,
            ),
            padding: AppShape.buttonPadding,
          ),
        ),

        // ── Outlined Button ───────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.buttonOutlineDefault,
            foregroundColor: AppColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: AppShape.radiusMd,
            ),
            padding: AppShape.buttonPadding,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),

        // ── Chip ──────────────────────────────────────
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.chipUnselected,
          selectedColor: AppColors.chipSelected,
          labelStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppShape.radiusFull,
          ),
          padding: AppShape.chipPadding,
        ),

        // ── Bottom Navigation Bar (GNB) ───────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.gnbBackground,
          selectedItemColor: AppColors.gnbActive,
          unselectedItemColor: AppColors.gnbInactive,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Input Decoration ──────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: const OutlineInputBorder(
            borderRadius: AppShape.radiusMd,
            borderSide: BorderSide(color: AppColors.textTertiary),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppShape.radiusMd,
            borderSide: BorderSide(color: AppColors.textTertiary),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppShape.radiusMd,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: AppShape.radiusMd,
            borderSide: BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMd.copyWith(
            color: AppColors.textTertiary,
          ),
        ),

        // ── Card ──────────────────────────────────────
        cardTheme: const CardThemeData(
          color: AppColors.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppShape.radiusMd,
          ),
        ),
      );
}
