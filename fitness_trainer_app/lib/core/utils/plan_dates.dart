import 'package:shamsi_date/shamsi_date.dart';

/// Days left in a plan, from its Jalali `yyyy/MM/dd` [startDate] and its
/// [days] duration. Returns `null` when the plan has no usable start date
/// (queued plans have none) or the key is unreadable.
///
/// Pure date maths — it deliberately does NOT look at the plan status, so the
/// same number can be used for display *and* for deciding that a plan has run
/// out of time. The end date is `startDate + days`, so a 30-day course starting
/// 1404/01/01 reports 30 days left on its first day and 0 from day 31 onwards.
///
/// The exact Julian-day difference is used: rebuilding a `DateTime` from the
/// Jalali components would treat them as Gregorian and drift by a day or two
/// across months (e.g. اسفند ۳۰ becoming "March 2").
int? planRemainingDays({required String? startDate, required int days, DateTime? today}) {
  if (startDate == null || startDate.isEmpty) return null;
  final parts = startDate.split('/');
  if (parts.length != 3) return null;
  final Jalali start;
  try {
    start = Jalali(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  } catch (_) {
    // Out-of-range or unparsable Jalali key — treat as "unknown" instead of
    // letting a corrupt row crash a list screen.
    return null;
  }
  final end = start.addDays(days);
  final now = Jalali.fromDateTime(today ?? DateTime.now());
  final diff = end.distanceFrom(now);
  return diff > 0 ? diff : 0;
}

/// Whether [startDate]/[days] have run their course as of [today]
/// (i.e. the plan has 0 days left). `false` when the dates are unknown.
bool planDaysElapsed({required String? startDate, required int days, DateTime? today}) =>
    planRemainingDays(startDate: startDate, days: days, today: today) == 0;
