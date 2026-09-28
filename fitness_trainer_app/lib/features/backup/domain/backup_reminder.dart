import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';

/// Decides how urgently the backup reminder is shown.
///
/// This app has no server: every record lives in the user's own browser
/// storage, which the app does not control and cannot protect. A cleared
/// browser, an eviction under storage pressure, or a lost phone is therefore
/// total, unrecoverable data loss — a live user lost their entire database this
/// way and was saved only by a two-day-old file they happened to have.
///
/// The reminder is permanent for that reason; this class only decides how
/// loudly it is shown. The rules stay pure and unit-tested rather than buried
/// in a widget.
class BackupReminder {
  /// How old a backup may get before the reminder is shown as a warning.
  ///
  /// This is also the worst case for data loss, since everything entered after
  /// the newest backup is gone if the storage is wiped. Kept short on purpose.
  static const int intervalDays = 7;

  /// Whether the newest backup is old enough to deserve a warning.
  ///
  /// [lastBackup] is a Jalali `yyyy/MM/dd` key (or null). [today] is passed in
  /// rather than read from the clock so tests are stable.
  static bool isOverdue({
    required String? lastBackup,
    required String today,
  }) {
    final days = daysSince(lastBackup, today);
    // Null means "never backed up" or an unreadable date; both are overdue.
    if (days == null) return true;
    return days >= intervalDays;
  }

  /// Whole days between [lastBackup] and [today], or null when [lastBackup] is
  /// null/unreadable (the caller should treat that as "no usable backup").
  static int? daysSince(String? lastBackup, String today) {
    if (lastBackup == null) return null;
    final from = jalaliToDateTime(lastBackup);
    final to = jalaliToDateTime(today);
    if (from == null || to == null) return null;
    return to.difference(from).inDays;
  }
}
