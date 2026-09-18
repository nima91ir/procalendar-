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
import 'package:fitness_trainer_app/features/clients/presentation/widgets/client_card.dart';
import 'package:fitness_trainer_app/main.dart';

/// Pumps fixed frames: several screens show indeterminate progress
/// indicators, which `pumpAndSettle` would wait on forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

int _selectedTab(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

Widget _harness(AppDatabase db, {Widget? home, String? initialRoute}) {
  return ProviderScope(
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
      home: home,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    ),
  );
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await ClientsService(ClientsRepository(db)).createClient('سارا محمدی');
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('dashboard stat card switches to the clients tab', (tester) async {
    await tester.pumpWidget(_harness(db, home: const MainShell()));
    await settle(tester);

    expect(_selectedTab(tester), 0);

    await tester.tap(find.byIcon(Icons.event_busy));
    await tester.pump();
    await settle(tester);

    expect(_selectedTab(tester), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard "view clients" action switches tabs instead of pushing', (tester) async {
    await tester.pumpWidget(_harness(db, home: const MainShell()));
    await settle(tester);

    await tester.tap(find.text('مشاهده مشتریان'));
    await tester.pump();
    await settle(tester);

    expect(_selectedTab(tester), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown route renders the not-found page instead of throwing', (tester) async {
    await tester.pumpWidget(
      _harness(
        db,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/does-not-exist'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('go'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('صفحه مورد نظر پیدا نشد'), findsOneWidget);
  });

  testWidgets('client card calendar shortcut opens attendance', (tester) async {
    await tester.pumpWidget(_harness(db, home: const MainShell()));
    await settle(tester);

    final clientsIcon = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.people_outline),
    );
    await tester.tap(clientsIcon);
    await tester.pump();
    await settle(tester);

    final shortcut = find.descendant(
      of: find.byType(ClientCard),
      matching: find.byIcon(Icons.calendar_month_outlined),
    );
    await tester.tap(shortcut);
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('وضعیت جلسات'), findsOneWidget);
  });
}
