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

void main() {
  testWidgets('tapping a client in the list opens the client detail screen', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await ClientsService(ClientsRepository(db)).createClient('سارا محمدی');

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
          home: const HeroMode(enabled: false, child: MainShell()),
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

    expect(find.text('مشتریان'), findsWidgets);
    expect(find.text('سارا محمدی'), findsOneWidget);

    await tester.tap(find.text('سارا محمدی'));
    await settle(tester);

    // Client bottom sheet with quick actions.
    expect(find.text('مشاهده پروفایل'), findsOneWidget);
    expect(find.text('ثبت سریع امروز'), findsOneWidget);
    expect(find.text('حاضر'), findsOneWidget);
    expect(find.text('غایب'), findsOneWidget);
    expect(find.text('ویرایش مشتری'), findsOneWidget);
    expect(find.text('حذف مشتری'), findsOneWidget);

    await tester.tap(find.text('مشاهده پروفایل'));
    await settle(tester);

    // Detail screen markers.
    expect(find.text('اطلاعات تماس'), findsOneWidget);
    expect(find.text('برنامه‌ها'), findsOneWidget);
  });
}