import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/presentation/add_edit_client_screen.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/main.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget buildHarness(AppDatabase db, {Widget? home, String? initialRoute}) {
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
      home: home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: initialRoute,
    ),
  );
}

void main() {
  group('Client tag assignment', () {
    late AppDatabase db;
    late int clientId;
    late int assignedTagId;
    late int otherTagId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      clientId = await ClientsService(ClientsRepository(db)).createClient('سارا');
      final tags = TagsService(TagsRepository(db));
      assignedTagId = await tags.createTag('ویژه');
      otherTagId = await tags.createTag('VIP');
      await tags.assignTagToClient(clientId, assignedTagId);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('edit form lists assigned tags and can add another', (tester) async {
      await tester.pumpWidget(
        buildHarness(db, home: AddEditClientScreen(clientId: clientId)),
      );
      await settle(tester);

      expect(find.text('برچسب‌ها'), findsOneWidget);
      expect(find.text('ویژه'), findsOneWidget);

      await tester.tap(find.text('افزودن برچسب'));
      await settle(tester);

      await tester.tap(find.text('VIP'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'ذخیره'));
      await settle(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'ذخیره'));
      await settle(tester);

      expect((await db.getClientTagIds(clientId)).toSet(), {assignedTagId, otherTagId});
    });

    testWidgets('client detail can remove a tag', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          db,
          initialRoute: '/clients/detail/$clientId',
        ),
      );
      await settle(tester);

      expect(find.text('ویژه'), findsOneWidget);

      await tester.tap(find.text('ویژه'));
      await settle(tester);

      await tester.tap(find.descendant(of: find.byType(FilterChip), matching: find.text('ویژه')));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'ذخیره'));
      await settle(tester);

      expect(await db.getClientTagIds(clientId), isEmpty);
    });
  });
}
