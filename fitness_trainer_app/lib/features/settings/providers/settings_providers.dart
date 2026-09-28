import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_theme_spec.dart';
import 'package:fitness_trainer_app/core/widgets/ui_scale.dart';
import 'package:fitness_trainer_app/features/settings/data/settings_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(settingsRepositoryProvider), ref.watch(databaseProvider));
});

final trainerNameProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.watch(settingsServiceProvider).getTrainerName();
});

/// Theme mode persisted in the `app_settings` table.
///
/// The switch in Settings was previously wired to an empty callback and
/// `MaterialApp.themeMode` was hardcoded to [ThemeMode.system].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final stored = await ref.read(settingsServiceProvider).getThemePreference();
      state = _parse(stored);
    } catch (_) {
      // The database is not ready (or not available). Keep the default
      // theme instead of failing the whole app build.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsServiceProvider).setThemePreference(mode.name);
  }

  static ThemeMode _parse(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Selected app theme, persisted in `app_settings`. `MaterialApp` watches it, so
/// switching a theme re-tints every screen instantly.
///
/// The stored id is resolved through [AppThemes.byId], which falls back to the
/// default rather than throwing — a value written by a newer build, or a theme
/// that was renamed, can never leave the app with no palette at all.
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeSpec>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppThemeSpec> {
  @override
  AppThemeSpec build() {
    _load();
    return AppThemes.fallback;
  }

  Future<void> _load() async {
    try {
      final stored = await ref.read(settingsServiceProvider).getThemeIdPreference();
      if (stored != null) state = AppThemes.byId(stored);
    } catch (_) {
      // Database not ready; keep the default theme.
    }
  }

  Future<void> setTheme(AppThemeSpec theme) async {
    if (theme.id == state.id) return;
    state = theme;
    await ref.read(settingsServiceProvider).setThemeIdPreference(theme.id);
  }
}

/// Selected language code ('fa' or 'en'), persisted in `app_settings`.
///
/// `MaterialApp.locale` is driven from this provider so switching language
/// rebuilds the whole widget tree (and flips RTL/LTR automatically).
final languageProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'fa';
  }

  Future<void> _load() async {
    try {
      final stored = await ref.read(settingsServiceProvider).getLanguagePreference();
      if (stored == 'fa' || stored == 'en') {
        state = stored!;
      }
    } catch (_) {
      // Database not ready; keep 'fa'.
    }
  }

  Future<void> setLanguage(String code) async {
    state = code;
    await ref.read(settingsServiceProvider).setLanguagePreference(code);
  }
}

/// Display size, persisted in `app_settings` and applied by
/// `MaterialApp.builder`, so every screen shrinks or grows together.
///
/// Splitting preview from persist is deliberate: a slider writes on every frame
/// it moves, and round-tripping each tick through the database would both stutter
/// and hammer it. [preview] changes the state only — which is what makes the
/// change visible live — and [persist] writes once, when the drag ends.
final uiScaleProvider = NotifierProvider<UiScaleNotifier, double>(UiScaleNotifier.new);

class UiScaleNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return kUiScaleDefault;
  }

  Future<void> _load() async {
    try {
      final stored = await ref.read(settingsServiceProvider).getUiScalePreference();
      state = parseUiScale(stored);
    } catch (_) {
      // Database not ready; keep the default size.
    }
  }

  /// Live preview while the slider is being dragged. Not persisted.
  void preview(double scale) {
    state = scale.clamp(kUiScaleMin, kUiScaleMax);
  }

  /// Writes the current value. Call when the drag ends.
  Future<void> persist() async {
    await ref.read(settingsServiceProvider).setUiScalePreference(state);
  }
}
