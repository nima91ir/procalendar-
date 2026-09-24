import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/backup/providers/backup_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

/// Dashboard nudge to make a backup.
///
/// Everything this app stores lives in the user's own browser storage — there is
/// no server and no second copy — so a cleared browser or a lost phone is
/// unrecoverable without a backup file. This banner is the only thing that
/// warns about that.
///
/// It renders nothing unless [BackupReminder] says the user is due, so it
/// disappears on its own once a backup is made. "Later" snoozes it via the
/// existing `app_settings` key/value table (no schema change).
class BackupReminderBanner extends ConsumerWidget {
  const BackupReminderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `.value` keeps this silent while loading, and a read failure simply hides
    // a reminder — never blocks the dashboard.
    final state = ref.watch(backupReminderProvider).value;
    if (state == null || !state.due) return const SizedBox.shrink();

    final s = AppStrings.of(context);
    final t = context.tones;
    final lang = ref.watch(languageProvider);
    final lastBackup = state.lastBackup;
    final days = BackupReminder.daysSince(lastBackup, jalaliToday());

    return Container(
      // The banner owns its own bottom gap so the dashboard's spacing is
      // identical to before when the banner is hidden.
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: t.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: t.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.backup_outlined, size: 20, color: t.warning),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      days == null ? s.lastBackupNever : s.backupReminderDueTitle(days),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: t.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      days == null || lastBackup == null
                          ? s.backupReminderNeverBody
                          : s.lastBackupOn(formatDateShort(lastBackup, lang)),
                      style: AppTypography.caption.copyWith(color: t.onSurfaceVar),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FilledButton(
                // Settings is index 4 in MainShell's tab order — the same
                // hardcoded-index pattern the dashboard's own action uses.
                onPressed: () => ref.read(tabIndexProvider.notifier).select(4),
                child: Text(s.backupReminderGo),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () => _snooze(ref),
                child: Text(s.backupReminderLater),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _snooze(WidgetRef ref) async {
    await ref
        .read(settingsServiceProvider)
        .setBackupSnoozeUntil(BackupReminder.snoozeUntilFrom(DateTime.now()));
    ref.invalidate(backupReminderProvider);
  }
}
