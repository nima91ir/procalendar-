import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brightness-aware semantic colors.
///
/// [AppColors] is the brand palette (base hues + gradients) and is intentionally
/// brightness-independent. It used to double as the *only* palette, which broke
/// dark mode: light-only pastels ([AppColors.surface], `*Soft` pills,
/// [AppColors.primaryLight]) and dark-only text ([AppColors.onSurface],
/// [AppColors.onSurfaceVar]) were rendered verbatim on dark surfaces.
///
/// [AppTones] resolves every semantic slot for the current brightness. Widgets
/// must read it via `context.tones` (or `AppTones.of(context)`) instead of
/// reaching for [AppColors] surface/text/soft tokens.
@immutable
class AppTones {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color onPrimary;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;

  final Color surface;
  final Color surfaceVariant;
  final Color background;
  final Color onSurface;
  final Color onSurfaceVar;
  final Color outline;
  final Color outlineVariant;

  final Color today;
  final Color todaySoft;
  final Color todayInk;
  final Color present;
  final Color absent;
  final Color queued;
  final Color frozen;

  const AppTones({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.onPrimary,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.surface,
    required this.surfaceVariant,
    required this.background,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.outline,
    required this.outlineVariant,
    required this.today,
    required this.todaySoft,
    required this.todayInk,
    required this.present,
    required this.absent,
    required this.queued,
    required this.frozen,
  });

  static AppTones of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = AppTones(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryLight: AppColors.primaryLight,
    onPrimary: Colors.white,
    success: AppColors.success,
    successSoft: AppColors.successSoft,
    warning: AppColors.warning,
    warningSoft: AppColors.warningSoft,
    error: AppColors.error,
    errorSoft: AppColors.errorSoft,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    background: AppColors.background,
    onSurface: AppColors.onSurface,
    onSurfaceVar: AppColors.onSurfaceVar,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    today: AppColors.today,
    todaySoft: AppColors.todaySoft,
    todayInk: AppColors.todayInk,
    present: AppColors.present,
    absent: AppColors.absent,
    queued: AppColors.queued,
    frozen: AppColors.frozen,
  );

  static const dark = AppTones(
    primary: Color(0xFF9DBE7E),
    primaryDark: Color(0xFF7FA365),
    primaryLight: Color(0xFF33422F),
    onPrimary: Color(0xFF1F2A1E),
    success: Color(0xFF8FCF9A),
    successSoft: Color(0xFF243326),
    warning: Color(0xFFE9C77E),
    warningSoft: Color(0xFF3A2F1C),
    error: Color(0xFFEE9C8E),
    errorSoft: Color(0xFF3A2320),
    surface: Color(0xFF1F2A1E),
    surfaceVariant: Color(0xFF2A3829),
    background: Color(0xFF161D15),
    onSurface: Color(0xFFE3F0E5),
    onSurfaceVar: Color(0xFFA9BC9E),
    outline: Color(0xFF4A5A4A),
    outlineVariant: Color(0xFF3A4A39),
    today: Color(0xFFFFB74D),
    todaySoft: Color(0xFF3A2C15),
    todayInk: Color(0xFFFFCC80),
    present: Color(0xFF66BB6A),
    absent: Color(0xFFE57373),
    queued: Color(0xFFFFB74D),
    frozen: Color(0xFF64B5F6),
  );
}

extension AppTonesContext on BuildContext {
  /// Semantic, brightness-aware palette for the current theme.
  AppTones get tones => AppTones.of(this);
}
