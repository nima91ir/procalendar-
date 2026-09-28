import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/platform/file_saver_provider.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/backup/providers/backup_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

/// Dashboard reminder to back up, shown permanently.
///
/// Everything this app stores lives in the user's own browser storage: there is
/// no server and no second copy, and the app neither controls that storage nor
/// can protect it. A cleared browser, an eviction under storage pressure, or a
/// lost phone therefore destroys the lot — which is exactly what happened to a
/// live user, who was saved only by a two-day-old file they happened to have.
///
/// It used to appear only once the backup was overdue, and could be dismissed
/// with "later". That is how a user ends up going weeks without one, so it is
/// now always on screen and the copy says plainly why. [BackupReminder] only
/// decides how loudly it is drawn.
class BackupReminderBanner extends ConsumerStatefulWidget {
  const BackupReminderBanner({super.key});

  @override
  ConsumerState<BackupReminderBanner> createState() => _BackupReminderBannerState();
}

class _BackupReminderBannerState extends ConsumerState<BackupReminderBanner> {
  /// Guards the export button against a double tap while the file is written.
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    // `.value` is null while the read is in flight. The card still renders — it
    // is permanent — but without the last-backup line, so it never briefly
    // claims "never backed up" to someone who has one.
    final state = ref.watch(backupReminderProvider).value;
    final s = AppStrings.of(context);
    final t = context.tones;
    final language = ref.watch(languageProvider);
    final lastBackup = state?.lastBackup;
    final days = BackupReminder.daysSince(lastBackup, jalaliToday());
    final overdue = state?.overdue ?? false;

    return Container(
      // The banner owns its own bottom gap so the dashboard's spacing is
      // identical to before when the banner is hidden.
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // Amber only once the backup is genuinely old. A recent one still shows
        // the card, but as information rather than as an alarm, so the warning
        // colour keeps meaning something.
        color: overdue ? t.warningSoft : t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: overdue ? t.warning.withValues(alpha: 0.35) : t.outlineVariant,
        ),
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
                  color: (overdue ? t.warning : t.primary).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.backup_outlined,
                  size: 20,
                  color: overdue ? t.warning : t.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.backupReminderTitle,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: t.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Why this card never goes away. Nobody would guess that the
                    // app does not own the storage holding their records, and
                    // that is the whole reason a backup file is the only safety
                    // net that exists here.
                    Text(
                      s.backupReminderWhy,
                      style: AppTypography.caption.copyWith(color: t.onSurfaceVar),
                    ),
                    if (state != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        days == null || lastBackup == null
                            ? s.lastBackupNever
                            : '${s.lastBackupOn(formatDateShort(lastBackup, language))} · ${s.daysAgo(days)}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: overdue ? t.warning : t.onSurfaceVar,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Wrap, not Row: the two labels together are wider than a small phone
          // and a Row overflows there (measured: 64px at 320 logical wide, which
          // the narrow-width test in backup_reminder_banner_test.dart pins).
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                // One tap, right here. Getting a backup used to mean Settings ->
                // scroll -> button, which is a large part of why a live user had
                // none.
                onPressed: _busy ? null : () => _export(context),
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt),
                label: Text(s.backupReminderGo),
              ),
              TextButton(
                // Restoring a file and the CSV exports still live in Settings, so
                // the card keeps a way through to them. Settings is index 4 in
                // MainShell's tab order — the same hardcoded-index pattern the
                // dashboard's own actions use.
                onPressed: () => ref.read(tabIndexProvider.notifier).select(4),
                child: Text(s.settingsTitle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Writes a backup file and records the date.
  ///
  /// Mirrors `_exportJson` in `settings_screen.dart` on purpose: the two entry
  /// points may not drift apart, and this stays small enough to compare by eye.
  Future<void> _export(BuildContext context) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final name = 'procalendar-backup-${BackupService.timestampSuffix()}.json';
      // Through the provider rather than `saveTextFile` directly: the test VM has
      // no platform channel to answer the native saver, so a direct call could
      // never be observed or tested.
      final saved = await ref.read(textFileSaverProvider)(name, json);
      // Only on a non-null result: the IO implementation returns null when the
      // save was cancelled, and recording that would claim a backup exists when
      // it does not — the one lie this feature cannot afford.
      if (saved != null) {
        await ref.read(settingsServiceProvider).setLastBackupDate(jalaliToday());
        ref.invalidate(backupReminderProvider);
      }
      messenger.showSnackBar(SnackBar(content: Text(s.backupSaved(saved ?? name))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(s.backupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
