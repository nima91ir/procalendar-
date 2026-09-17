import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: '/clients',
        ),
      ),
    );
    await settle(tester);

    expect(find.text('مشتریان'), findsWidgets);
    expect(find.text('سارا محمدی'), findsOneWidget);

    await tester.tap(find.text('سارا محمدی'));
    await settle(tester);

    // Detail screen markers.
    expect(find.text('اطلاعات تماس'), findsOneWidget);
    expect(find.text('برنامه‌های فعال'), findsOneWidget);
  });
}