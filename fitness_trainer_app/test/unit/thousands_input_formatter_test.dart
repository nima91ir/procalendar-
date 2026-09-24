import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/utils/thousands_input_formatter.dart';

/// The price field must read `1,000,000` while it is typed, and still parse
/// with `int.tryParse(text.replaceAll(',', ''))`.
void main() {
  group('ThousandsSeparatorInputFormatter', () {
    const formatter = ThousandsSeparatorInputFormatter();

    TextEditingValue format(String text) => formatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: text),
        );

    test('groups digits in threes', () {
      expect(format('1000000').text, '1,000,000');
      expect(format('1000').text, '1,000');
      expect(format('999').text, '999');
      expect(format('1234567890').text, '1,234,567,890');
    });

    test('is idempotent over already grouped text', () {
      const grouped = TextEditingValue(text: '1,000,000');
      expect(formatter.formatEditUpdate(grouped, grouped).text, '1,000,000');
    });

    test('drops anything that is not a digit', () {
      expect(format('1,000,000 تومان').text, '1,000,000');
      expect(format('1 000 000').text, '1,000,000');
      expect(format('').text, '');
      expect(format('abc').text, '');
    });

    test('normalises Persian and Arabic-Indic digits', () {
      expect(format('۱۲۳').text, '123');
      expect(format('٤٥٦').text, '456');
    });

    test('renders Persian digits when asked', () {
      const persian = ThousandsSeparatorInputFormatter(persianDigits: true);
      final value = persian.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1000000'),
      );
      expect(value.text, '۱,۰۰۰,۰۰۰');
    });

    test('leaves the caret at the end of the formatted text', () {
      final value = format('1000000');
      expect(value.selection.baseOffset, value.text.length);
      expect(value.selection.isCollapsed, isTrue);
    });
  });

  group('groupDigits', () {
    test('matches the display grouping used by AppStrings.money', () {
      expect(groupDigits(0), '0');
      expect(groupDigits(1000), '1,000');
      expect(groupDigits(1000000), '1,000,000');
      expect(groupDigits(-250000), '-250,000');
    });
  });
}
