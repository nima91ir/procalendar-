import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_theme_spec.dart';
import 'app_typography.dart';
import 'app_tokens.dart';

class AppTheme {
  static const fontFamily = AppTypography.fontFamily;

  /// The default theme (light), kept for tests and back-compat.
  static ThemeData get light => lightFor();

  /// The default theme (dark), kept for tests and back-compat.
  static ThemeData get dark => darkFor();

  static ThemeData lightFor([AppThemeSpec? theme]) =>
      _build(theme ?? AppThemes.fallback, Brightness.light);

  static ThemeData darkFor([AppThemeSpec? theme]) =>
      _build(theme ?? AppThemes.fallback, Brightness.dark);

  /// Every component theme below reads the palette, so a theme repaints the
  /// whole surface layer rather than only the cards. Status colours stay on
  /// [AppColors] — they carry meaning, not brand.
  static ThemeData _build(AppThemeSpec theme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? theme.dark : theme.light;
    final primary = p.primary;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [AppThemeData(theme: theme)],
      // `secondary`/`secondaryContainer` are set from the palette too: several
      // Material widgets (SegmentedButton among them) tint their selection from
      // these, so leaving them at the M3 default painted teal segments on every
      // theme. `tertiary` likewise, for anything that reaches for it.
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: p.onPrimary,
              secondary: p.primaryDark,
              secondaryContainer: p.primaryLight,
              tertiary: p.primaryDark,
              tertiaryContainer: p.primaryLight,
              surface: p.surface,
              onSurface: p.onSurface,
              outline: p.outline,
              error: AppColors.darkError,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: p.onPrimary,
              secondary: p.primaryDark,
              secondaryContainer: p.primaryLight,
              tertiary: p.primaryDark,
              tertiaryContainer: p.primaryLight,
              surface: p.surface,
              onSurface: p.onSurface,
              outline: p.outline,
              error: AppColors.error,
            ),
      fontFamily: fontFamily,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: p.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      // A 44 minimum height on the two primary-action button families.
      //
      // They rendered ~32 tall, well below the 44 guideline — and because
      // Material pads the *tap* area behind that, the real target was larger
      // than the button looked. Matching the two makes what you see and what you
      // hit the same size, which is the point.
      //
      // TextButton is deliberately excluded: it is used inline (section headers,
      // "show all" links), where a 44 minimum would stretch rows meant to stay
      // dense. It is a tertiary control, not a primary action.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          minimumSize: const Size(0, 44),
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
        indicatorColor: p.primaryLight,
        backgroundColor: p.surface,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: p.onSurfaceVar,
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
      dividerTheme: DividerThemeData(color: p.outlineVariant),
    );
    return base;
  }
}