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

  Future<String?> getThemePreference() => repository.getSetting('theme');
  Future<void> setThemePreference(String theme) => repository.setSetting('theme', theme);

  Future<String?> getAccentPreference() => repository.getSetting('accent');
  Future<void> setAccentPreference(String accent) => repository.setSetting('accent', accent);

  Future<String?> getLanguagePreference() => repository.getSetting('language');
  Future<void> setLanguagePreference(String code) => repository.setSetting('language', code);

  // --- Backup-reminder bookkeeping -------------------------------------------
  // Both values are Jalali `yyyy/MM/dd` keys, like every other date this app
  // stores. Nothing here needs a schema change: they ride on the existing
  // key/value `app_settings` table, so live databases at v7 are untouched.

  static const _lastBackupKey = 'last_backup_date';
  static const _snoozeKey = 'backup_snooze_until';

  Future<String?> getLastBackupDate() => repository.getSetting(_lastBackupKey);

  Future<void> setLastBackupDate(String jalaliDate) =>
      repository.setSetting(_lastBackupKey, jalaliDate);

  Future<String?> getBackupSnoozeUntil() => repository.getSetting(_snoozeKey);

  Future<void> setBackupSnoozeUntil(String jalaliDate) =>
      repository.setSetting(_snoozeKey, jalaliDate);

  Future<Map<String, String>> getAllSettings() async {
    final rows = await db.select(db.appSettings).get();
    return {for (var r in rows) r.key: r.value};
  }
}
