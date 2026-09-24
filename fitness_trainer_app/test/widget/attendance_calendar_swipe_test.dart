import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';

/// The month grid is swipeable. Swiping "forward" advances the month, mirrored
/// for RTL so it matches the chevrons, and the gesture must not swallow the day
/// taps or hijack a vertical scroll.
void main() {
  group('AttendanceCalendar swipe', () {
    late int previousCount;
    late int nextCount;
    late List<String> tapped;

    /// [language] decides the direction: `fa` renders RTL (like the app),
    /// `en` renders LTR.
    Future<void> pumpCalendar(WidgetTester tester, {String language = 'fa'}) async {
      previousCount = 0;
      nextCount = 0;
      tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          home: Scaffold(
            body: AttendanceCalendar(
              year: 1405,
              month: 6,
              attendanceMap: const <String, List<String>>{},
              onDayTapped: tapped.add,
              onPreviousMonth: () => previousCount++,
              onNextMonth: () => nextCount++,
              todayKey: '1405/06/27',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> swipe(WidgetTester tester, double dx) async {
      await tester.fling(find.byType(AttendanceCalendar), Offset(dx, 0), 1000);
      await tester.pumpAndSettle();
    }

    testWidgets('RTL: swiping right goes to the next month', (tester) async {
      await pumpCalendar(tester);
      await swipe(tester, 300);
      expect(nextCount, 1);
      expect(previousCount, 0);
    });

    testWidgets('RTL: swiping left goes to the previous month', (tester) async {
      await pumpCalendar(tester);
      await swipe(tester, -300);
      expect(previousCount, 1);
      expect(nextCount, 0);
    });

    testWidgets('LTR: swiping left goes to the next month', (tester) async {
      await pumpCalendar(tester, language: 'en');
      await swipe(tester, -300);
      expect(nextCount, 1);
      expect(previousCount, 0);
    });

    testWidgets('a vertical drag leaves the month alone', (tester) async {
      await pumpCalendar(tester);
      await tester.drag(find.byType(AttendanceCalendar), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(nextCount, 0);
      expect(previousCount, 0);
    });

    testWidgets('tapping a day still reports the day and does not change month', (tester) async {
      await pumpCalendar(tester);
      await tester.tap(find.text('۲۷'));
      await tester.pumpAndSettle();
      expect(tapped, ['1405/06/27']);
      expect(nextCount, 0);
      expect(previousCount, 0);
    });

    testWidgets('a swipe is ignored when the calendar has no month callbacks', (tester) async {
      // Picker-less usage (no callbacks) must not attach a drag recogniser that
      // swallows anything.
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      await swipe(tester, 300);
      expect(tester.takeException(), isNull);
    });
  });
}
