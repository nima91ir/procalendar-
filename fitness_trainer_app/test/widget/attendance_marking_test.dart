import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/past_attendance_screen.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';

/// Pumps a few frames instead of `pumpAndSettle`, because the app-bar
/// progress indicator animates indefinitely while a mutation is in flight.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('Attendance marking screen', () {
    late AppDatabase db;
    late int clientId;
    late int planId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final templateId = await TemplatesService(TemplatesRepository(db)).createTemplate('T', 5, 30);
      final plansService = PlansService(PlansRepository(db), db);
      clientId = await ClientsService(ClientsRepository(db)).createClient('سارا');
      planId = await plansService.assignPlan(clientId, templateId, 5, 30);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            locale: const Locale('fa'),
            supportedLocales: const [Locale('fa'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: PastAttendanceScreen(clientId: clientId),
          ),
        ),
      );
      await settle(tester);
    }

    testWidgets('shows the session summary and the calendar', (tester) async {
      await pumpScreen(tester);
      expect(find.text('وضعیت جلسات'), findsOneWidget);
      // 5 of 5 sessions available, rendered with Persian digits.
      expect(find.text('۵ از ۵'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('tapping "حاضر" consumes one session from the active plan', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'حاضر +'));
      await settle(tester);

      expect((await db.getPlan(planId))!.remaining, 4);
      expect(find.text('۴ از ۵'), findsOneWidget);
    });

    testWidgets('undo gives the session back', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'حاضر +'));
      await settle(tester);
      expect((await db.getPlan(planId))!.remaining, 4);

      // Let the confirmation SnackBar time out so it can't block the tap.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));

      // The record card is below the calendar, so scroll it into view first.
      await tester.scrollUntilVisible(
        find.widgetWithIcon(IconButton, Icons.delete_outline),
        200,
      );
      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await settle(tester);

      // M3: deleting a session now asks for confirmation first.
      await tester.tap(find.widgetWithText(ElevatedButton, 'حذف'));
      await settle(tester);

      expect((await db.getPlan(planId))!.remaining, 5);
      expect((await db.select(db.attendance).get()), isEmpty);
    });
  });
}