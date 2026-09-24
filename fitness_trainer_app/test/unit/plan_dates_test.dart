import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/utils/plan_dates.dart';

/// The plan expiry sweep depends on this number: `0` means "the duration has
/// run out", and `null` means "there is no start date to measure from" (queued
/// plans) — so the sweep must not treat `null` as expired.
void main() {
  group('planRemainingDays', () {
    // Fixed anchor so the expectations cannot drift with the clock. Only the
    // day *offsets* below matter, not the absolute Jalali date.
    final today = DateTime(2026, 9, 24);
    final jToday = Jalali.fromDateTime(today);

    /// Jalali `yyyy/MM/dd` key for [days] before [today] (negative = after).
    String startBefore(int days) {
      final j = jToday.addDays(-days);
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    }

    test('counts the days left from the start date', () {
      expect(planRemainingDays(startDate: startBefore(0), days: 30, today: today), 30);
      expect(planRemainingDays(startDate: startBefore(1), days: 30, today: today), 29);
      expect(planRemainingDays(startDate: startBefore(29), days: 30, today: today), 1);
    });

    test('reports 0 on the last day and stays 0 afterwards', () {
      // This is the case the app got wrong: 0 days left has to mean "expired",
      // i.e. 30 days after the plan started.
      expect(planRemainingDays(startDate: startBefore(30), days: 30, today: today), 0);
      expect(planRemainingDays(startDate: startBefore(31), days: 30, today: today), 0);
      expect(planRemainingDays(startDate: '1400/01/01', days: 30, today: today), 0);
      expect(planDaysElapsed(startDate: startBefore(30), days: 30, today: today), isTrue);
    });

    test('a future start date still reports the full duration', () {
      expect(planRemainingDays(startDate: startBefore(-10), days: 30, today: today), 40);
      expect(planDaysElapsed(startDate: startBefore(-10), days: 30, today: today), isFalse);
    });

    test('unknown or unreadable dates report null, never 0', () {
      expect(planRemainingDays(startDate: null, days: 30, today: today), isNull);
      expect(planRemainingDays(startDate: '', days: 30, today: today), isNull);
      expect(planRemainingDays(startDate: '1405/07', days: 30, today: today), isNull);
      expect(planRemainingDays(startDate: '1405/13/40', days: 30, today: today), isNull);
      expect(planDaysElapsed(startDate: null, days: 30, today: today), isFalse);
    });
  });
}
