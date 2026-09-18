import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/main.dart';

/// Pumps fixed frames: several screens show indeterminate progress
/// indicators, which `pumpAndSettle` would wait on forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpShell(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShell(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );
  await settle(tester);

  final bottomNav = find.byType(NavigationBar);
  final clientsIcon = find.descendant(of: bottomNav, matching: find.byIcon(Icons.people_outline));
  await tester.tap(clientsIcon);
  await tester.pump();
  await settle(tester);
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final plans = PlansService(PlansRepository(db), db);
    final templates = TemplatesService(TemplatesRepository(db), plansService: plans);
    final clients = ClientsService(ClientsRepository(db));
    await clients.createClient('مهدی رضایی');
    await templates.createTemplate('قالب آزمون', 8, 30);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('creating a plan refreshes the client detail plans list in place', (tester) async {
    await pumpShell(tester, db);

    await tester.tap(find.text('مهدی رضایی'));
    await settle(tester);
    expect(find.text('اطلاعات تماس'), findsOneWidget);

    await tester.tap(find.text('افزودن برنامه'));
    await settle(tester);
    expect(find.text('انتخاب قالب برنامه'), findsOneWidget);

    await tester.tap(find.text('قالب آزمون'));
    await settle(tester);
    await tester.tap(find.text('انتخاب این قالب'));
    await settle(tester);
    await tester.tap(find.text('بله، ثبت شود'));
    await settle(tester);

    // Back on the detail screen without leaving it.
    expect(find.text('انتخاب قالب برنامه'), findsNothing);
    expect(find.text('اطلاعات تماس'), findsOneWidget);

    // The plans list lives below the fold; it must be there without any
    // navigation round-trip.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await settle(tester);
    expect(find.text('قالب آزمون'), findsOneWidget);
    expect(find.text('فعال'), findsOneWidget);
  });
}