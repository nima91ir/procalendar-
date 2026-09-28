import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';

class SettingsRepository {
  final AppDatabase db;
  SettingsRepository(this.db);

  Future<String?> getSetting(String key) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await db.into(db.appSettings).insert(
      AppSettingsCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }
}

class SettingsService {
  final SettingsRepository repository;
  final AppDatabase db;
  SettingsService(this.repository, this.db);

  Future<String?> getTrainerName() => repository.getSetting('trainer_name');
  Future<void> setTrainerName(String name) => repository.setSetting('trainer_name', name);

  /// Light/dark **mode**: `system` | `light` | `dark`.
  Future<String?> getThemePreference() => repository.getSetting('theme');
  Future<void> setThemePreference(String theme) => repository.setSetting('theme', theme);

  /// Palette **theme id** (see `AppThemes`).
  ///
  /// Deliberately a different key from the one above. The light/dark mode
  /// already owns `theme`, and sharing it would make picking a theme silently
  /// reset light/dark — or worse, have the mode overwrite the theme.
  Future<String?> getThemeIdPreference() => repository.getSetting('theme_id');
  Future<void> setThemeIdPreference(String id) => repository.setSetting('theme_id', id);

  Future<String?> getAccentPreference() => repository.getSetting('accent');
  Future<void> setAccentPreference(String accent) => repository.setSetting('accent', accent);

  Future<String?> getLanguagePreference() => repository.getSetting('language');
  Future<void> setLanguagePreference(String code) => repository.setSetting('language', code);

  // --- Backup-reminder bookkeeping -------------------------------------------
  // A Jalali `yyyy/MM/dd` key, like every other date this app stores. Nothing
  // here needs a schema change: it rides on the existing key/value
  // `app_settings` table, so live databases at v7 are untouched.
  //
  // The old `backup_snooze_until` key is left in place rather than migrated
  // away: the reminder is permanent now, so nothing reads it, and an unused row
  // in a key/value table costs nothing.

  static const _lastBackupKey = 'last_backup_date';
  static const _uiScaleKey = 'ui_scale';

  Future<String?> getLastBackupDate() => repository.getSetting(_lastBackupKey);

  Future<void> setLastBackupDate(String jalaliDate) =>
      repository.setSetting(_lastBackupKey, jalaliDate);

  /// Display size, stored as a plain number string. Read it through
  /// `parseUiScale` so a missing or out-of-range value cannot be applied.
  Future<String?> getUiScalePreference() => repository.getSetting(_uiScaleKey);

  Future<void> setUiScalePreference(double scale) =>
      repository.setSetting(_uiScaleKey, scale.toString());

  Future<Map<String, String>> getAllSettings() async {
    final rows = await db.select(db.appSettings).get();
    return {for (var r in rows) r.key: r.value};
  }
}
