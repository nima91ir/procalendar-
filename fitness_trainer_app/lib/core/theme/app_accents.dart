import 'package:flutter/material.dart';

/// Selectable brand accents for the theme.
///
/// Every accent defines a light and a dark primary triad plus the hero-header
/// gradient. Surfaces and semantic status colours stay accent-independent and
/// are owned by [AppTones]; only the brand **primary** family varies here.
enum AppAccent { green, blue, purple, rose, orange, teal }

class AccentPalette {
  const AccentPalette({
    required this.lightPrimary,
    required this.lightPrimaryDark,
    required this.lightPrimaryLight,
    required this.darkPrimary,
    required this.darkPrimaryDark,
    required this.darkPrimaryLight,
    required this.gradientPrimary,
  });

  final Color lightPrimary;
  final Color lightPrimaryDark;
  final Color lightPrimaryLight;
  final Color darkPrimary;
  final Color darkPrimaryDark;
  final Color darkPrimaryLight;

  /// Accent gradient used by hero headers in both brightnesses.
  final List<Color> gradientPrimary;
}

/// Green (the brand default) + five curated accents.
class AccentPalettes {
  static const green = AccentPalette(
    lightPrimary: Color(0xFF88A36B),
    lightPrimaryDark: Color(0xFF6B8452),
    lightPrimaryLight: Color(0xFFB8C9A8),
    darkPrimary: Color(0xFF9DBE7E),
    darkPrimaryDark: Color(0xFF7FA365),
    darkPrimaryLight: Color(0xFF33422F),
    gradientPrimary: [Color(0xFF93AE7A), Color(0xFF6B8452)],
  );

  static const blue = AccentPalette(
    lightPrimary: Color(0xFF5B8DB8),
    lightPrimaryDark: Color(0xFF3D6B92),
    lightPrimaryLight: Color(0xFFA5C3DD),
    darkPrimary: Color(0xFF7FB2E0),
    darkPrimaryDark: Color(0xFF5B8DB8),
    darkPrimaryLight: Color(0xFF1F3545),
    gradientPrimary: [Color(0xFF7FA8CC), Color(0xFF3D6B92)],
  );

  static const purple = AccentPalette(
    lightPrimary: Color(0xFF8E7BB8),
    lightPrimaryDark: Color(0xFF6D5A96),
    lightPrimaryLight: Color(0xFFC3B6E0),
    darkPrimary: Color(0xFFAB9BD4),
    darkPrimaryDark: Color(0xFF8E7BB8),
    darkPrimaryLight: Color(0xFF2C2440),
    gradientPrimary: [Color(0xFFA392CC), Color(0xFF6D5A96)],
  );

  static const rose = AccentPalette(
    lightPrimary: Color(0xFFC26B7C),
    lightPrimaryDark: Color(0xFF9E4F60),
    lightPrimaryLight: Color(0xFFE0BBC3),
    darkPrimary: Color(0xFFD98B9A),
    darkPrimaryDark: Color(0xFFC26B7C),
    darkPrimaryLight: Color(0xFF3E2329),
    gradientPrimary: [Color(0xFFD08A98), Color(0xFF9E4F60)],
  );

  static const orange = AccentPalette(
    lightPrimary: Color(0xFFC98A3C),
    lightPrimaryDark: Color(0xFFA56B2A),
    lightPrimaryLight: Color(0xFFE8C79A),
    darkPrimary: Color(0xFFE0A45C),
    darkPrimaryDark: Color(0xFFC98A3C),
    darkPrimaryLight: Color(0xFF402E15),
    gradientPrimary: [Color(0xFFD99F52), Color(0xFFA56B2A)],
  );

  static const teal = AccentPalette(
    lightPrimary: Color(0xFF3E9E8C),
    lightPrimaryDark: Color(0xFF2F7E70),
    lightPrimaryLight: Color(0xFFA8D8CE),
    darkPrimary: Color(0xFF6BC4B2),
    darkPrimaryDark: Color(0xFF3E9E8C),
    darkPrimaryLight: Color(0xFF15322C),
    gradientPrimary: [Color(0xFF55B5A2), Color(0xFF2F7E70)],
  );

  static const _all = <AppAccent, AccentPalette>{
    AppAccent.green: green,
    AppAccent.blue: blue,
    AppAccent.purple: purple,
    AppAccent.rose: rose,
    AppAccent.orange: orange,
    AppAccent.teal: teal,
  };

  static AccentPalette of(AppAccent accent) => _all[accent]!;

  static List<AppAccent> get values => _all.keys.toList();
}

/// Stashed on [ThemeData] so [AppTones] can resolve the active accent without
/// a global. Falls back to green when absent (tests, startup error screen).
class AccentThemeData extends ThemeExtension<AccentThemeData> {
  const AccentThemeData({required this.accent});

  final AppAccent accent;

  @override
  AccentThemeData copyWith({AppAccent? accent}) =>
      AccentThemeData(accent: accent ?? this.accent);

  @override
  AccentThemeData lerp(AccentThemeData? other, double t) => other ?? this;
}