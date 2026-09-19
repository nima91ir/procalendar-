import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_accents.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_tokens.dart';

class AppTheme {
  static const fontFamily = AppTypography.fontFamily;

  /// Green brand theme (light), kept for tests and back-compat.
  static ThemeData get light => lightForAccent();

  /// Green brand theme (dark), kept for tests and back-compat.
  static ThemeData get dark => darkForAccent();

  static ThemeData lightForAccent([AppAccent accent = AppAccent.green]) =>
      _build(accent, Brightness.light);

  static ThemeData darkForAccent([AppAccent accent = AppAccent.green]) =>
      _build(accent, Brightness.dark);

  static ThemeData _build(AppAccent accent, Brightness brightness) {
    final p = AccentPalettes.of(accent);
    final primary = brightness == Brightness.dark ? p.darkPrimary : p.lightPrimary;
    final onPrimary = brightness == Brightness.dark ? AppColors.onSurface : Colors.white;
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [AccentThemeData(accent: accent)],
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: onPrimary,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkOnSurface,
              outline: AppColors.darkOutline,
              error: AppColors.darkError,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
              outline: AppColors.outline,
              error: AppColors.error,
            ),
      fontFamily: fontFamily,
      scaffoldBackgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: isDark ? p.darkPrimaryLight : p.lightPrimaryLight,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOutline : AppColors.onSurfaceVar,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant,
      ),
    );
    return base;
  }
}