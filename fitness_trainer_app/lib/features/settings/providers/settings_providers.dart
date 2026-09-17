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

final themePreferenceProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.watch(settingsServiceProvider).getThemePreference();
});
