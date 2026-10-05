import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';

/// Left-to-right isolate (U+2066) and pop directional isolate (U+2069).
const String lri = '\u2066';
const String pdi = '\u2069';

/// [AppStrings.money] must render a money figure inside an LTR isolate.
///
/// A money figure is a left-to-right run, but the paragraph around it is
/// Persian and therefore right-to-left. Without the isolate the bidi algorithm
/// can lay the digit groups out under the paragraph's direction, so `۲,۰۰۰,۰۰۰`
/// renders as `۰,۰۰۰,۰۰۲` — visually reversed, which reads as a different
/// amount. These tests pin the isolate in place so it cannot be dropped.
void main() {
  group('AppStrings.money isolates the number for bidi', () {
    test('wraps a large grouped amount in an LTR isolate', () {
      final rendered = AppStrings.fa.money(2000000);

      expect(rendered.startsWith(lri), isTrue);
      expect(rendered.endsWith(pdi), isTrue);
      expect(
        rendered.substring(1, rendered.length - 1),
        '۲,۰۰۰,۰۰۰',
      );
    });

    test('keeps the isolate on a negative amount', () {
      final rendered = AppStrings.fa.money(-1500);

      expect(rendered.startsWith(lri), isTrue);
      expect(rendered.endsWith(pdi), isTrue);
      // The leading `-` is part of the same left-to-right run, so it stays
      // inside the isolate with the digits rather than being pushed to the far
      // side of an RTL paragraph.
      expect(rendered.substring(1, rendered.length - 1), '-۱,۵۰۰');
    });

    test('keeps the isolate on zero and on a small amount', () {
      for (final amount in [0, 7, 999]) {
        final rendered = AppStrings.fa.money(amount);
        expect(rendered.startsWith(lri), isTrue, reason: 'amount $amount');
        expect(rendered.endsWith(pdi), isTrue, reason: 'amount $amount');
      }
    });

    test('isolates English digits too, not just Persian ones', () {
      final rendered = AppStrings.en.money(2000000);

      expect(rendered.startsWith(lri), isTrue);
      expect(rendered.endsWith(pdi), isTrue);
      expect(rendered.substring(1, rendered.length - 1), '2,000,000');
    });

    test('carries no isolate other than the one wrapping the digits', () {
      // Guards against a stray directional mark leaking into the string from
      // an earlier edit: exactly two control characters, at the ends.
      final rendered = AppStrings.fa.money(123456789);
      final controls = rendered.runes.where((r) => r == 0x2066 || r == 0x2069);

      expect(controls.length, 2);
      expect(rendered.indexOf(lri), 0);
    });

    test('does not leak the isolate into digits()', () {
      // The isolate belongs to money() alone. digits() is used for counts and
      // chips, where a direction mark would be visible garbage.
      expect(AppStrings.fa.digits(2000000), '۲۰۰۰۰۰۰');
      expect(AppStrings.fa.digits(2000000).contains(lri), isFalse);
    });
  });
}
