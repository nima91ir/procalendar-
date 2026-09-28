import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';

/// The backup reminder is the only thing in the app that warns the user their
/// entire database lives in browser storage, so its thresholds are pinned here
/// rather than left to the widget that renders it.
///
/// The reminder is always on screen now; `isOverdue` only decides how loudly it
/// is drawn, so these tests pin when it stops being calm.
///
/// Dates are always derived from `jalaliToday()` with an offset, so these tests
/// do not break when the clock rolls over.
void main() {
  final today = jalaliToday();

  String daysBack(int days) => addJalaliDays(today, -days);

  bool overdue(String? lastBackup) =>
      BackupReminder.isOverdue(lastBackup: lastBackup, today: today);

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

  group('isOverdue', () {
    test('warns when the user has never backed up', () {
      expect(overdue(null), isTrue);
    });

    test('stays calm one day before the interval', () {
      expect(overdue(daysBack(BackupReminder.intervalDays - 1)), isFalse);
    });

    test('warns exactly on the interval', () {
      expect(overdue(daysBack(BackupReminder.intervalDays)), isTrue);
    });

    test('warns long after the interval', () {
      expect(overdue(daysBack(BackupReminder.intervalDays * 3)), isTrue);
    });

    test('warns when the stored date is unreadable', () {
      expect(overdue('not-a-date'), isTrue);
    });

    test('a backup taken today is never a warning', () {
      expect(overdue(daysBack(0)), isFalse);
    });
  });
}
