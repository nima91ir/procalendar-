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
    await ClientsService(ClientsRepository(db)).createClient('سارا محمدی');
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('tapping a client in the list opens the client detail screen', (tester) async {
    await pumpShell(tester, db);

    expect(find.text('مشتریان'), findsWidgets);
    expect(find.text('سارا محمدی'), findsOneWidget);

    await tester.tap(find.text('سارا محمدی'));
    await settle(tester);

    // Detail screen markers (the "برنامه‌ها" label also appears on the bottom
    // navigation bar, which stays visible with nested navigators).
    expect(find.text('اطلاعات تماس'), findsOneWidget);
    expect(find.text('برنامه‌ها'), findsWidgets);
  });

  testWidgets('long-pressing a client opens the quick actions sheet', (tester) async {
    await pumpShell(tester, db);

    await tester.longPress(find.text('سارا محمدی'));
    await settle(tester);

    expect(find.text('ثبت سریع امروز'), findsOneWidget);
    expect(find.text('حاضر'), findsOneWidget);
    expect(find.text('غایب'), findsOneWidget);
    expect(find.text('ویرایش مشتری'), findsOneWidget);
    expect(find.text('حذف مشتری'), findsOneWidget);
  });
}
