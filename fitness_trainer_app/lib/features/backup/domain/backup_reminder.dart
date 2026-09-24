import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';

/// Decides when to nudge the user to make a backup.
///
/// This app has no server: every record lives in the user's own browser
/// storage, so a cleared browser or a lost phone is total, unrecoverable data
/// loss. This is the only thing in the app that warns about it, so the rules
/// are kept pure and unit-tested instead of being buried in a widget.
class BackupReminder {
  /// Nudge once the newest backup is at least this many days old.
  static const int intervalDays = 14;

  /// How long "later" silences the banner for.
  static const int snoozeDays = 2;

  /// The Jalali key the snooze should be set to when the user taps "later".
  static String snoozeUntilFrom(DateTime now) =>
      addJalaliDays(jalaliFromDateTime(now), snoozeDays);

  /// Whether the banner should be visible.
  ///
  /// [lastBackup] and [snoozedUntil] are Jalali `yyyy/MM/dd` keys (or null).
  /// [today] is passed in rather than read from the clock so tests are stable.
  static bool isDue({
    required String? lastBackup,
    required String? snoozedUntil,
    required String today,
  }) {
    // Jalali keys are zero-padded, so lexicographic order is chronological.
    if (snoozedUntil != null && today.compareTo(snoozedUntil) < 0) return false;
    final days = daysSince(lastBackup, today);
    // Null means "never backed up" or an unreadable date; both should prompt.
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
