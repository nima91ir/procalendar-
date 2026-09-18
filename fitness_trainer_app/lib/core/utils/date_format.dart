import 'package:shamsi_date/shamsi_date.dart';
import 'jalali_calendar.dart';
import 'persian_numbers.dart';

/// Locale-aware date formatting.
///
/// The app stores every date as a Jalali `yyyy/MM/dd` key (that is the
/// calendar it is built around), but the UI can render it either in the
/// Persian/Shamsi calendar or as the equivalent Gregorian date depending on
/// the selected language.
const _gregorianMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _gregorianDays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

String? _parseKey(String date) {
  final parts = date.split('/');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return '$y/$m/$d';
}

Jalali? _toJalali(String date) {
  final key = _parseKey(date);
  if (key == null) return null;
  final parts = key.split('/');
  return Jalali(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// Long date string for the given language, e.g.
/// Persian: «شنبه ۲۵ اسفند ۱۴۰۴», English: «Saturday, 15 March 2026».
String formatDateLong(String jalaliKey, String languageCode) {
  if (languageCode == 'en') {
    final j = _toJalali(jalaliKey);
    if (j == null) return jalaliKey;
    final g = j.toGregorian();
    final dt = DateTime(g.year, g.month, g.day);
    final day = _gregorianDays[dt.weekday - 1];
    final month = _gregorianMonths[g.month - 1];
    return '$day, ${g.day} $month ${g.year}';
  }
  return formatJalaliLong(jalaliKey);
}

/// Short date string for the given language, e.g.
/// Persian: «۱۴۰۴/۱۲/۲۵», English: «2026/03/15».
String formatDateShort(String jalaliKey, String languageCode) {
  final key = _parseKey(jalaliKey);
  if (key == null) return jalaliKey;
  if (languageCode == 'en') {
    final j = _toJalali(key);
    if (j == null) return jalaliKey;
    final g = j.toGregorian();
    final m = g.month.toString().padLeft(2, '0');
    final d = g.day.toString().padLeft(2, '0');
    return '${g.year}/$m/$d';
  }
  return formatJalali(key);
}

/// Formats a numeric value using Persian digits when [languageCode] is
/// Persian ("fa"), otherwise keeps Western digits.
String localizeNumber(String value, String languageCode) =>
    languageCode == 'fa' ? toPersian(value) : value;