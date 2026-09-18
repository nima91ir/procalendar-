import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';

/// Mirrors the app's locale wiring so `AppStrings.of(context)` resolves to
/// Persian (the app's default language).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget buildHarness(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DashboardScreen(),
    ),
  );
}

void main() {
  group('Dashboard today attendance', () {
    late AppDatabase db;
    late int clientId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      clientId = await ClientsService(ClientsRepository(db)).createClient('سارا');
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('can mark the same client more than once in one day', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);

      await tester.pumpWidget(buildHarness(container));
      await settle(tester);

      final presentButton = find.text('ثبت حضور');
      expect(presentButton, findsOneWidget);
      expect(find.byIcon(Icons.undo), findsNothing);

      await tester.tap(presentButton);
      await tester.pumpAndSettle();

      // The quick buttons stay available so a second record can be added.
      expect(find.text('ثبت حضور'), findsOneWidget);
      expect(find.byIcon(Icons.undo), findsOneWidget);

      await tester.tap(presentButton);
      await tester.pumpAndSettle();

      final today = jalaliToday();
      final records = await db.getClientAttendance(clientId);
      expect(records.where((r) => r.date == today).length, 2);

      await tester.tap(find.byIcon(Icons.undo));
      await tester.pumpAndSettle();

      final afterUndo = await db.getClientAttendance(clientId);
      expect(afterUndo.where((r) => r.date == today).length, 1);
    });
  });
}