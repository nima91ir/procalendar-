import 'package:shamsi_date/shamsi_date.dart';
import 'persian_numbers.dart';

/// Jalali `yyyy/MM/dd` key for today, matching the format used by the
/// attendance table and calendars.
String jalaliToday() {
  final now = DateTime.now();
  final j = Jalali.fromDateTime(now);
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

/// Adds [days] to a Jalali `yyyy/MM/dd` date and returns a `yyyy/MM/dd` key.
/// Leap years (اسفند ۳۰) are handled by [Jalali.addDays].
String addJalaliDays(String date, int days) {
  final parts = date.split('/');
  if (parts.length != 3) return date;
  final j = Jalali(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final target = j.addDays(days);
  return '${target.year}/${target.month.toString().padLeft(2, '0')}/${target.day.toString().padLeft(2, '0')}';
}

/// Parses a Jalali `yyyy/MM/dd` key into a Gregorian [DateTime] at local
/// midnight, or null when the key is unreadable.
///
/// This is for **arithmetic** only (e.g. "how many days ago?"). Display should
/// keep using the Jalali key via [formatDateShort]/[formatJalaliLong].
DateTime? jalaliToDateTime(String date) {
  final parts = date.split('/');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  try {
    return Jalali(y, m, d).toDateTime();
  } catch (_) {
    // Out-of-range Jalali date (e.g. 1405/13/40) — treat as unreadable rather
    // than letting a corrupt setting crash a screen.
    return null;
  }
}

/// Jalali `yyyy/MM/dd` key for an arbitrary [DateTime].
String jalaliFromDateTime(DateTime date) {
  final j = Jalali.fromDateTime(date);
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

String formatJalali(String date) {
  final parts = date.split('/');
  if (parts.length != 3) return date;
  final y = toPersian(parts[0]);
  final m = toPersian(parts[1]);
  final d = toPersian(parts[2]);
  return '$y/$m/$d';
}

const monthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
];

String formatJalaliLong(String date) {
  final parts = date.split('/');
  if (parts.length != 3) return date;
  final j = Jalali(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  final dayNames = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'];
  final dayName = dayNames[j.weekDay - 1];
  final monthName = monthNames[j.month - 1];
  return '$dayName ${toPersian(j.day.toString())} $monthName ${toPersian(j.year.toString())}';
}
