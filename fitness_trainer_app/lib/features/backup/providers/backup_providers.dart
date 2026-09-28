import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

/// What the backup reminder needs: when the newest backup was made (a Jalali
/// key, or null) and whether it is old enough to warn about.
class BackupReminderState {
  final String? lastBackup;
  final bool overdue;

  const BackupReminderState({required this.lastBackup, required this.overdue});
}

/// Reads the last-backup date and applies [BackupReminder].
///
/// Invalidate this after a successful backup so the reminder updates at once
/// instead of waiting for a rebuild.
final backupReminderProvider = FutureProvider.autoDispose<BackupReminderState>((ref) async {
  final settings = ref.watch(settingsServiceProvider);
  final last = await settings.getLastBackupDate();
  return BackupReminderState(
    lastBackup: last,
    overdue: BackupReminder.isOverdue(lastBackup: last, today: jalaliToday()),
  );
});

/// How many records the database actually holds.
///
/// Shown in Settings so the user can see at a glance that the numbers still look
/// right. That is the check that was missing when a live user's database was
/// wiped: the app looked normal and nobody could tell whether the zeros were
/// real. Counted in SQL so a year of attendance is never loaded to count it.
///
/// The table names are written out because this schema is frozen at v7 — new
/// columns go through migrations and the tables themselves cannot be renamed.
class DataHealth {
  final int clients;
  final int plans;
  final int attendance;

  const DataHealth({
    required this.clients,
    required this.plans,
    required this.attendance,
  });
}

final dataHealthProvider = FutureProvider.autoDispose<DataHealth>((ref) async {
  final db = ref.watch(databaseProvider);

  Future<int> countRows(String table) async {
    final row = await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
    return row.read<int>('c');
  }

  return DataHealth(
    clients: await countRows('clients'),
    plans: await countRows('client_plans'),
    attendance: await countRows('attendance'),
  );
});
