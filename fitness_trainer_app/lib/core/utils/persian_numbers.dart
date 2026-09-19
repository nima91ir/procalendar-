String toPersian(String input) {
  const map = {
    '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
    '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
  };
  return input.replaceAllMapped(RegExp(r'[0-9]'), (m) => map[m.group(0)]!);
}

/// Converts Persian (۰-۹) and Arabic-Indic (٠-٩) digits to ASCII so that
/// `int.tryParse` accepts amount/price/session input typed on a Persian
/// keyboard layout. Keeps other characters (commas, spaces) untouched.
String toLatinDigits(String input) {
  const map = {
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  };
  return input.replaceAllMapped(
    RegExp(r'[۰-۹٠-٩]'),
    (m) => map[m.group(0)]!,
  );
}
