import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

/// What the dashboard reminder needs: the last backup (Jalali key or null) and
/// whether the user should be nudged right now.
class BackupReminderState {
  final String? lastBackup;
  final bool due;

  const BackupReminderState({required this.lastBackup, required this.due});
}

/// Reads the two persisted dates and applies [BackupReminder].
///
/// Invalidate this after a successful backup (and after snoozing) so the banner
/// reacts immediately instead of waiting for a rebuild.
final backupReminderProvider = FutureProvider.autoDispose<BackupReminderState>((ref) async {
  final settings = ref.watch(settingsServiceProvider);
  final last = await settings.getLastBackupDate();
  final snoozedUntil = await settings.getBackupSnoozeUntil();
  return BackupReminderState(
    lastBackup: last,
    due: BackupReminder.isDue(
      lastBackup: last,
      snoozedUntil: snoozedUntil,
      today: jalaliToday(),
    ),
  );
});
