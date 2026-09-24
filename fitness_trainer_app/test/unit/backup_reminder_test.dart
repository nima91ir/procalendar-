import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';

/// The backup reminder is the only thing in the app that warns the user their
/// entire database lives in browser storage, so its thresholds are pinned here
/// rather than left to the widget that renders it.
///
/// Dates are always derived from `jalaliToday()` with an offset, so these tests
/// do not break when the clock rolls over.
void main() {
  final today = jalaliToday();

  String daysBack(int days) => addJalaliDays(today, -days);

  bool due(String? lastBackup, {String? snoozedUntil}) => BackupReminder.isDue(
        lastBackup: lastBackup,
        snoozedUntil: snoozedUntil,
        today: today,
      );

  group('daysSince', () {
    test('counts whole days between two Jalali keys', () {
      expect(BackupReminder.daysSince(daysBack(0), today), 0);
      expect(BackupReminder.daysSince(daysBack(13), today), 13);
      expect(BackupReminder.daysSince(daysBack(40), today), 40);
    });

    test('is null when there is no backup at all', () {
      expect(BackupReminder.daysSince(null, today), isNull);
    });

    test('is null when the stored key is unreadable', () {
      expect(BackupReminder.daysSince('not-a-date', today), isNull);
      // Out-of-range Jalali date: month 13 does not exist.
      expect(BackupReminder.daysSince('1405/13/40', today), isNull);
    });
  });

  group('isDue', () {
    test('prompts when the user has never backed up', () {
      expect(due(null), isTrue);
    });

    test('stays quiet one day before the interval', () {
      expect(due(daysBack(BackupReminder.intervalDays - 1)), isFalse);
    });

    test('prompts exactly on the interval', () {
      expect(due(daysBack(BackupReminder.intervalDays)), isTrue);
    });

    test('prompts long after the interval', () {
      expect(due(daysBack(BackupReminder.intervalDays * 3)), isTrue);
    });

    test('prompts when the stored date is unreadable', () {
      expect(due('not-a-date'), isTrue);
    });

    test('stays quiet while a snooze has not expired', () {
      // Snoozed until tomorrow, even though the backup is long overdue.
      expect(due(daysBack(40), snoozedUntil: addJalaliDays(today, 1)), isFalse);
    });

    test('prompts again on the day the snooze expires', () {
      expect(due(daysBack(40), snoozedUntil: today), isTrue);
    });

    test('prompts again once the snooze is in the past', () {
      expect(due(daysBack(40), snoozedUntil: addJalaliDays(today, -1)), isTrue);
    });

    test('a snooze silences the never-backed-up prompt too', () {
      expect(due(null, snoozedUntil: addJalaliDays(today, 1)), isFalse);
    });
  });

  group('snoozeUntilFrom', () {
    test('pushes the banner out by snoozeDays', () {
      final until = BackupReminder.snoozeUntilFrom(DateTime.now());

      expect(until, addJalaliDays(today, BackupReminder.snoozeDays));
      expect(BackupReminder.daysSince(today, until), BackupReminder.snoozeDays);
    });
  });
}
