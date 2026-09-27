import 'package:flutter/material.dart';

/// A selectable app theme.
///
/// A theme owns the **surface layer** — backgrounds, cards, ink, borders — plus
/// the brand accent it pairs with by default. The accent stays separately
/// selectable on top, so a theme is a starting point rather than a cage.
///
/// ### Adding a theme
/// Append one [AppThemeSpec] to [AppThemes.all]. Nothing else needs to change:
/// the picker, persistence and `ThemeData` all read from that list. Ids are
/// stored in `app_settings`, so **never rename an existing id** — that would
/// silently reset the choice for anyone using it.
@immutable
class AppThemeSpec {
  const AppThemeSpec({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.swatches,
    required this.light,
    required this.dark,
  });

  /// Stable key persisted in `app_settings`. Do not rename.
  final String id;
  final String nameFa;
  final String nameEn;

  /// Four representative colours for the picker — surface, fill, ink, accent.
  final List<Color> swatches;

  final AppThemePalette light;
  final AppThemePalette dark;

  /// Corner radius for cards. `null` keeps the app's current [AppRadius], which
  /// is deliberate: themes change colour only for now. Rounding is a per-widget
  /// concern (45 call sites), so it is a later pass — but the field lives here
  /// so that pass becomes a data change rather than a refactor.
  double? get cardRadius => null;
}

/// The surface layer of one theme in one brightness.
///
/// Only what actually differs between themes lives here. Status colours
/// (success/warning/error and their soft variants) stay shared — they carry
/// meaning, so letting a theme repaint them would change what the UI says, not
/// just how it looks.
@immutable
class AppThemePalette {
  const AppThemePalette({
    required this.surface,
    required this.surfaceVariant,
    required this.background,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.onPrimary,
    required this.gradientPrimary,
  });

  /// Cards and sheets.
  final Color surface;

  /// Fills: inputs, inactive chips, quiet rows.
  final Color surfaceVariant;

  /// Scaffold behind the cards.
  final Color background;

  final Color onSurface;

  /// Secondary text — labels, captions, metadata.
  final Color onSurfaceVar;

  final Color outline;

  /// Hairlines and dividers.
  final Color outlineVariant;

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color onPrimary;

  /// Hero-header gradient.
  final List<Color> gradientPrimary;
}

/// Carries the active [AppThemeSpec] through the widget tree, so `context.tones`
/// and the picker can find it without threading it through constructors.
@immutable
class AppThemeData extends ThemeExtension<AppThemeData> {
  const AppThemeData({required this.theme});

  final AppThemeSpec theme;

  @override
  AppThemeData copyWith({AppThemeSpec? theme}) =>
      AppThemeData(theme: theme ?? this.theme);

  @override
  AppThemeData lerp(ThemeExtension<AppThemeData>? other, double t) {
    // Palettes are discrete choices, not a continuum — snapping is honest here
    // and avoids interpolating between two unrelated colour schemes mid-animation.
    if (other is! AppThemeData) return this;
    return t < 0.5 ? this : other;
  }
}

/// The theme registry.
///
/// The first entry is the default and the fallback for an unknown id. Ids are
/// persisted, so treat them as permanent.
class AppThemes {
  const AppThemes._();

  static const sage = AppThemeSpec(
    id: 'sage',
    nameFa: 'روشن آرام',
    nameEn: 'Soft Light',
    swatches: [Color(0xFFF5F8F1), Color(0xFFE8F1E2), Color(0xFF182318), Color(0xFF5C945B)],
    light: AppThemePalette(
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFE8F1E2),
      background: Color(0xFFF5F8F1),
      onSurface: Color(0xFF182318),
      onSurfaceVar: Color(0xFF687665),
      outline: Color(0xFFD9E4D5),
      outlineVariant: Color(0xFFE4EDE0),
      primary: Color(0xFF88A36B),
      primaryDark: Color(0xFF46653B),
      primaryLight: Color(0xFFDDEBD8),
      onPrimary: Color(0xFFFFFFFF),
      gradientPrimary: [Color(0xFF93AE7A), Color(0xFF6B8452)],
    ),
    dark: AppThemePalette(
      surface: Color(0xFF161C17),
      surfaceVariant: Color(0xFF242C24),
      background: Color(0xFF10150F),
      onSurface: Color(0xFFE4EAE2),
      onSurfaceVar: Color(0xFF9DAA99),
      outline: Color(0xFF3A4437),
      outlineVariant: Color(0xFF2A3327),
      primary: Color(0xFF9DBE7E),
      primaryDark: Color(0xFF7FA365),
      primaryLight: Color(0xFF33422F),
      onPrimary: Color(0xFF161C17),
      gradientPrimary: [Color(0xFF4A6340), Color(0xFF33472C)],
    ),
  );

  static const paper = AppThemeSpec(
    id: 'paper',
    nameFa: 'کاغذی',
    nameEn: 'Paper',
    swatches: [Color(0xFFF8F4EB), Color(0xFFEEE7D8), Color(0xFF25241F), Color(0xFF315A45)],
    light: AppThemePalette(
      surface: Color(0xFFFFFDF8),
      surfaceVariant: Color(0xFFEEE7D8),
      background: Color(0xFFF8F4EB),
      onSurface: Color(0xFF25241F),
      onSurfaceVar: Color(0xFF756F62),
      outline: Color(0xFFD5CBB8),
      outlineVariant: Color(0xFFE4DCCB),
      primary: Color(0xFF315A45),
      primaryDark: Color(0xFF22412F),
      primaryLight: Color(0xFFDCE7DF),
      onPrimary: Color(0xFFFFFDF8),
      gradientPrimary: [Color(0xFF3C6B53), Color(0xFF22412F)],
    ),
    dark: AppThemePalette(
      surface: Color(0xFF1D1C18),
      surfaceVariant: Color(0xFF2A2823),
      background: Color(0xFF15140F),
      onSurface: Color(0xFFE9E4D8),
      onSurfaceVar: Color(0xFFA69F8E),
      outline: Color(0xFF454034),
      outlineVariant: Color(0xFF302C23),
      primary: Color(0xFF6E9B7F),
      primaryDark: Color(0xFF527A63),
      primaryLight: Color(0xFF2B3A31),
      onPrimary: Color(0xFF15140F),
      gradientPrimary: [Color(0xFF33513F), Color(0xFF223528)],
    ),
  );

  static const blueprint = AppThemeSpec(
    id: 'blueprint',
    nameFa: 'فنی',
    nameEn: 'Blueprint',
    swatches: [Color(0xFFEEF6F8), Color(0xFFE0EFF3), Color(0xFF173C4A), Color(0xFF21758D)],
    light: AppThemePalette(
      surface: Color(0xFFF8FDFF),
      surfaceVariant: Color(0xFFE0EFF3),
      background: Color(0xFFEEF6F8),
      onSurface: Color(0xFF173C4A),
      onSurfaceVar: Color(0xFF5A7B83),
      outline: Color(0xFFA9CBD3),
      outlineVariant: Color(0xFFD2E5EA),
      primary: Color(0xFF21758D),
      primaryDark: Color(0xFF155A6E),
      primaryLight: Color(0xFFD3EAF1),
      onPrimary: Color(0xFFF8FDFF),
      gradientPrimary: [Color(0xFF2B8DA2), Color(0xFF174C5E)],
    ),
    dark: AppThemePalette(
      surface: Color(0xFF12222A),
      surfaceVariant: Color(0xFF1D323B),
      background: Color(0xFF0C191F),
      onSurface: Color(0xFFDCEBF0),
      onSurfaceVar: Color(0xFF8FAAB3),
      outline: Color(0xFF2F4C57),
      outlineVariant: Color(0xFF1F3640),
      primary: Color(0xFF5FB3C9),
      primaryDark: Color(0xFF3F93A9),
      primaryLight: Color(0xFF1B3D49),
      onPrimary: Color(0xFF0C191F),
      gradientPrimary: [Color(0xFF1E5F72), Color(0xFF123B48)],
    ),
  );

  static const sport = AppThemeSpec(
    id: 'sport',
    nameFa: 'ورزشی',
    nameEn: 'Sport',
    swatches: [Color(0xFFF5F7FB), Color(0xFFE7EDF7), Color(0xFF172641), Color(0xFF19335F)],
    light: AppThemePalette(
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFE7EDF7),
      background: Color(0xFFF5F7FB),
      onSurface: Color(0xFF172641),
      onSurfaceVar: Color(0xFF5D6E89),
      outline: Color(0xFFCCD7E8),
      outlineVariant: Color(0xFFDFE7F2),
      primary: Color(0xFF19335F),
      primaryDark: Color(0xFF0F2142),
      primaryLight: Color(0xFFD6E0F0),
      onPrimary: Color(0xFFFFFFFF),
      gradientPrimary: [Color(0xFF1D4775), Color(0xFF11294D)],
    ),
    dark: AppThemePalette(
      surface: Color(0xFF141A28),
      surfaceVariant: Color(0xFF202839),
      background: Color(0xFF0E131E),
      onSurface: Color(0xFFDDE4F1),
      onSurfaceVar: Color(0xFF93A2BB),
      outline: Color(0xFF36415A),
      outlineVariant: Color(0xFF242C3E),
      primary: Color(0xFF7C9ED4),
      primaryDark: Color(0xFF5C7FB5),
      primaryLight: Color(0xFF23324E),
      onPrimary: Color(0xFF0E131E),
      gradientPrimary: [Color(0xFF22446F), Color(0xFF16294A)],
    ),
  );

  static const mono = AppThemeSpec(
    id: 'mono',
    nameFa: 'مینیمال',
    nameEn: 'Mono',
    swatches: [Color(0xFFF8F8F6), Color(0xFFEDEDEB), Color(0xFF191A19), Color(0xFF252825)],
    light: AppThemePalette(
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFEDEDEB),
      background: Color(0xFFF8F8F6),
      onSurface: Color(0xFF191A19),
      onSurfaceVar: Color(0xFF747670),
      outline: Color(0xFFD9D9D4),
      outlineVariant: Color(0xFFE7E7E3),
      primary: Color(0xFF252825),
      primaryDark: Color(0xFF121312),
      primaryLight: Color(0xFFE2E3E0),
      onPrimary: Color(0xFFFFFFFF),
      gradientPrimary: [Color(0xFF33362F), Color(0xFF1C1D1B)],
    ),
    dark: AppThemePalette(
      surface: Color(0xFF141514),
      surfaceVariant: Color(0xFF222322),
      background: Color(0xFF0E0F0E),
      onSurface: Color(0xFFE6E7E4),
      onSurfaceVar: Color(0xFF9A9C96),
      outline: Color(0xFF3A3C39),
      outlineVariant: Color(0xFF282A28),
      primary: Color(0xFFC9CBC5),
      primaryDark: Color(0xFFA8AAA4),
      primaryLight: Color(0xFF2E302E),
      onPrimary: Color(0xFF0E0F0E),
      gradientPrimary: [Color(0xFF3A3D39), Color(0xFF232522)],
    ),
  );

  /// Every theme, in picker order. **The first entry is the default.**
  ///
  /// This is the single place to add a theme.
  static const all = <AppThemeSpec>[sage, paper, blueprint, sport, mono];

  static AppThemeSpec get fallback => all.first;

  /// Never throws: an id that is missing (or was written by a newer build) falls
  /// back to the default rather than leaving the app with no palette.
  static AppThemeSpec byId(String? id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return fallback;
  }
}
