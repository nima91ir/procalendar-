import 'package:shamsi_date/shamsi_date.dart';

/// The reporting window for the accounting screen.
///
/// Every transaction carries a Jalali `yyyy/MM/dd` date, so a period is just an
/// inclusive range of those keys and membership is a string comparison — the
/// keys are zero-padded, so lexicographic order is chronological order.
enum AccountingPeriod {
  today,
  thisMonth,
  lastMonth,
  last6Months,
  thisYear,

  /// No limit. The default, so the screen opens on the same numbers it showed
  /// before periods existed.
  lifetime,
}

/// An inclusive Jalali date range.
class DateRange {
  const DateRange(this.from, this.to);

  /// Inclusive `yyyy/MM/dd` keys.
  final String from;
  final String to;

  bool contains(String date) =>
      date.compareTo(from) >= 0 && date.compareTo(to) <= 0;
}

/// The range for [period], or `null` for [AccountingPeriod.lifetime].
///
/// [now] is passed in rather than read from the clock so this stays testable.
DateRange? rangeFor(AccountingPeriod period, {DateTime? now}) {
  if (period == AccountingPeriod.lifetime) return null;
  final today = Jalali.fromDateTime(now ?? DateTime.now());

  String key(Jalali j) =>
      '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';

  /// A whole Jalali month, first day to last. Jalali months are 29–31 days and
  /// Esfand varies with the leap year, so the length is read from the calendar
  /// rather than assumed.
  DateRange wholeMonth(int year, int month) {
    final first = Jalali(year, month, 1);
    return DateRange(key(first), key(Jalali(year, month, first.monthLength)));
  }

  switch (period) {
    case AccountingPeriod.today:
      return DateRange(key(today), key(today));
    case AccountingPeriod.thisMonth:
      return wholeMonth(today.year, today.month);
    case AccountingPeriod.lastMonth:
      // Farvardin (1) looks back into Esfand of the previous year.
      return today.month == 1
          ? wholeMonth(today.year - 1, 12)
          : wholeMonth(today.year, today.month - 1);
    case AccountingPeriod.last6Months:
      // Six months *including* the current one, so it is not silently eleven
      // months of data when the year rolls over.
      var year = today.year;
      var month = today.month - 5;
      while (month < 1) {
        month += 12;
        year -= 1;
      }
      return DateRange(key(Jalali(year, month, 1)), key(Jalali(today.year, today.month, today.monthLength)));
    case AccountingPeriod.thisYear:
      // Through Esfand 30, which is inclusive of 29 in a common year.
      return DateRange('${today.year}/01/01', '${today.year}/12/30');
    case AccountingPeriod.lifetime:
      return null;
  }
}
