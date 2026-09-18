import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Runs against a real (in-memory) database instead of the previous
    // un-overridden scope, where every provider resolved to an error.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ProCalendarApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('تقویم حرفه‌ای'), findsWidgets);
    expect(find.byType(RefreshIndicator), findsWidgets);
  });
}
