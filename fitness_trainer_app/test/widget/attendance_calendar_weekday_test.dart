import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';

/// Regression: `shamsi_date`'s [Jalali.weekDay] is Saturday-based
/// (شنبه = 1 … جمعه = 7), NOT the Gregorian Monday-based convention.
/// Both the long-date formatter and the month grid used `weekDay % 7`,
/// shifting every weekday by one (Friday rendered as «شنبه»).
void main() {
  group('formatJalaliLong weekday names', () {
    test('Friday renders as جمعه', () {
      // 2026-09-18 is a Friday → 1405/06/27.
      expect(formatJalaliLong('1405/06/27'), startsWith('جمعه '));
    });

    test('Saturday renders as شنبه', () {
      expect(formatJalaliLong('1405/06/28'), startsWith('شنبه '));
    });

    test('Sunday renders as یکشنبه', () {
      expect(formatJalaliLong('1405/06/29'), startsWith('یکشنبه '));
    });

    test('Wednesday renders as چهارشنبه', () {
      // 2026-09-23 is a Wednesday → 1405/07/01.
      expect(formatJalaliLong('1405/07/01'), startsWith('چهارشنبه '));
    });

    test('Thursday renders as پنج‌شنبه', () {
      expect(formatJalaliLong('1405/07/02'), startsWith('پنج‌شنبه '));
    });
  });

  group('AttendanceCalendar grid alignment', () {
    Future<void> pumpMonth(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AttendanceCalendar(
              year: 1405,
              month: 6,
              attendanceMap: const <String, List<String>>{},
              onDayTapped: (_) {},
              todayKey: '1405/06/27',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Friday the 27th sits under the جمعه column', (tester) async {
      await pumpMonth(tester);
      final header = tester.getCenter(find.text('ج'));
      final cell = tester.getCenter(find.text('۲۷'));
      expect((cell.dx - header.dx).abs() < 1.0, isTrue);
    });

    testWidgets('Saturday the 28th sits under the شنبه column', (tester) async {
      await pumpMonth(tester);
      final header = tester.getCenter(find.text('ش'));
      final cell = tester.getCenter(find.text('۲۸'));
      expect((cell.dx - header.dx).abs() < 1.0, isTrue);
    });
  });
}