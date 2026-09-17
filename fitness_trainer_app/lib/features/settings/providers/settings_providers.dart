import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
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
