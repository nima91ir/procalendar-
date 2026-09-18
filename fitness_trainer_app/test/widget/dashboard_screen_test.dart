import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';

/// Mirrors the app's locale wiring so `AppStrings.of(context)` resolves to
/// Persian (the app's default language).
Widget _harness(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

void main() {
  group('DashboardScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);
      expect(
        find.descendant(of: appBar, matching: find.text('تقویم حرفه‌ای')),
        findsOneWidget,
      );
    });

    testWidgets('renders the today attendance section', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(const DashboardScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('حضور امروز'),
        ),
        findsOneWidget,
      );
    });
  });
}