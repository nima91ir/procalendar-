import 'package:flutter/services.dart';

import 'persian_numbers.dart';

/// Groups a whole number with thousands separators: `1000000` → `1,000,000`.
/// Negative values keep a leading `-`.
///
/// Shared by the display helpers (`AppStrings.money`) and by
/// [ThousandsSeparatorInputFormatter], so a price can never be grouped two
/// different ways on the same screen.
String groupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

/// Live thousands-separator formatting for a whole-number input field, so a
/// price reads as `1,000,000` while it is being typed instead of `1000000`.
///
/// - Anything that is not a digit is dropped (pasted commas/spaces included),
///   so the field's text stays parseable with `int.tryParse`.
/// - Persian and Arabic-Indic digits are accepted and normalised to the
///   digits chosen by [persianDigits].
/// - The caret is pinned to the end: an amount is always typed left to right
///   and re-grouping shifts every offset, so there is no meaningful caret
///   position to preserve.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter({this.persianDigits = false});

  /// Render the result with Persian digits, matching the rest of the app.
  final bool persianDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = toLatinDigits(newValue.text).replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final grouped = groupDigits(int.parse(digits));
    final text = persianDigits ? toPersian(grouped) : grouped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
