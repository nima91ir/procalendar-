import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';

/// Mirrors the app's locale wiring so `AppStrings.of(context)` resolves to
/// Persian (the app's default language).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget buildHarness(AppDatabase db) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ClientsScreen(),
    ),
  );
}

void main() {
  group('Clients tag filter', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final clients = ClientsService(ClientsRepository(db));
      await clients.createClient('علی');
      await clients.createClient('مریم');
      await clients.createClient('رضا');
      final tags = TagsService(TagsRepository(db));
      final tagA = await tags.createTag('ویژه');
      final tagB = await tags.createTag('حرفهای');
      await tags.assignTagToClient(1, tagA);
      await tags.assignTagToClient(2, tagA);
      await tags.assignTagToClient(2, tagB);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('combining tags narrows the list (AND)', (tester) async {
      await tester.pumpWidget(buildHarness(db));
      await settle(tester);

      expect(find.text('علی'), findsOneWidget);
      expect(find.text('مریم'), findsOneWidget);
      expect(find.text('رضا'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'ویژه'));
      await settle(tester);

      expect(find.text('علی'), findsOneWidget);
      expect(find.text('مریم'), findsOneWidget);
      expect(find.text('رضا'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'حرفهای'));
      await settle(tester);

      expect(find.text('علی'), findsNothing);
      expect(find.text('مریم'), findsOneWidget);
      expect(find.text('رضا'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'همه'));
      await settle(tester);

      expect(find.text('علی'), findsOneWidget);
      expect(find.text('مریم'), findsOneWidget);
      expect(find.text('رضا'), findsOneWidget);
    });
  });
}