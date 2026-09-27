import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/features/accounting/domain/accounting_period.dart';

/// The accounting periods are pure date maths over Jalali `yyyy/MM/dd` keys, so
/// they are tested directly rather than through the screen.
///
/// The cases worth pinning are the ones that go wrong quietly: Farvardin looking
/// back into the previous year, six months crossing a year boundary, and Esfand
/// being 29 or 30 days depending on the leap year.
void main() {
  // Farvardin 1405 — the month that rolls back into 1404's Esfand.
  final farvardin = Jalali(1405, 1, 15).toDateTime();

  group('AccountingPeriod ranges', () {
    test('lifetime has no range at all', () {
      expect(rangeFor(AccountingPeriod.lifetime, now: farvardin), isNull);
    });

    test('today covers exactly one day', () {
      final range = rangeFor(AccountingPeriod.today, now: farvardin)!;
      expect(range.from, '1405/01/15');
      expect(range.to, '1405/01/15');
      expect(range.contains('1405/01/15'), isTrue);
      expect(range.contains('1405/01/14'), isFalse);
      expect(range.contains('1405/01/16'), isFalse);
    });

    test('this month spans the whole current Jalali month', () {
      final range = rangeFor(AccountingPeriod.thisMonth, now: farvardin)!;
      expect(range.from, '1405/01/01');
      // Farvardin is always 31 days.
      expect(range.to, '1405/01/31');
    });

    test('last month in Farvardin reaches back into the previous year', () {
      final range = rangeFor(AccountingPeriod.lastMonth, now: farvardin)!;
      expect(range.from, '1404/12/01');
      // Esfand is 29 or 30 days depending on the leap year, so bound the day
      // rather than assert one value; what matters is that it stays in 1404's
      // Esfand and stops before Farvardin.
      expect(range.contains('1404/12/25'), isTrue);
      expect(range.contains('1405/01/01'), isFalse);
    });

    test('last month mid-year stays in the same year', () {
      // Shahrivar 1405 -> Mordad 1405.
      final range = rangeFor(AccountingPeriod.lastMonth,
          now: Jalali(1405, 6, 10).toDateTime())!;
      expect(range.from, '1405/05/01');
      expect(range.contains('1405/05/31'), isTrue);
      expect(range.contains('1405/06/10'), isFalse);
    });

    test('six months includes the current month and crosses the year', () {
      final range = rangeFor(AccountingPeriod.last6Months, now: farvardin)!;
      // Farvardin is month 1, so six back lands on Aban of the previous year.
      expect(range.from, '1404/08/01');
      expect(range.to, '1405/01/31');
      expect(range.contains('1404/08/01'), isTrue);
      expect(range.contains('1404/07/30'), isFalse);
      expect(range.contains('1405/01/31'), isTrue);
    });

    test('this year covers the whole Jalali year', () {
      final range = rangeFor(AccountingPeriod.thisYear, now: farvardin)!;
      expect(range.from, '1405/01/01');
      expect(range.to, '1405/12/30');
      // Esfand 29 resolves inside the range even in a common year.
      expect(range.contains('1405/12/29'), isTrue);
      expect(range.contains('1404/12/29'), isFalse);
    });

    test('contains is inclusive at both ends', () {
      const range = DateRange('1405/01/01', '1405/01/31');
      expect(range.contains('1405/01/01'), isTrue);
      expect(range.contains('1405/01/31'), isTrue);
      expect(range.contains('1404/12/30'), isFalse);
      expect(range.contains('1405/02/01'), isFalse);
    });
  });
}
