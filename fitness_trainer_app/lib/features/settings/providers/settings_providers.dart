import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_accents.dart';
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

/// Selected brand accent, persisted in `app_settings`. `MaterialApp` watches
/// it so switching accent re-tints every screen instantly.
final accentProvider = NotifierProvider<AccentNotifier, AppAccent>(AccentNotifier.new);

class AccentNotifier extends Notifier<AppAccent> {
  @override
  AppAccent build() {
    _load();
    return AppAccent.green;
  }

  Future<void> _load() async {
    try {
      final stored = await ref.read(settingsServiceProvider).getAccentPreference();
      if (stored != null) {
        for (final accent in AppAccent.values) {
          if (accent.name == stored) {
            state = accent;
            return;
          }
        }
      }
    } catch (_) {
      // Database not ready; keep the default accent.
    }
  }

  Future<void> setAccent(AppAccent accent) async {
    if (accent == state) return;
    state = accent;
    await ref.read(settingsServiceProvider).setAccentPreference(accent.name);
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
