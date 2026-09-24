import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/presentation/widgets/client_card.dart';
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
  group('ClientCard quick actions', () {
    late AppDatabase db;
    late int clientId;
    late int planId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final templateId = await TemplatesService(TemplatesRepository(db)).createTemplate('T', 5, 30);
      final plansService = PlansService(PlansRepository(db), db);
      final clientsService = ClientsService(ClientsRepository(db));
      clientId = await clientsService.createClient('سارا', bonusSessions: 2);
      planId = await plansService.assignPlan(clientId, templateId, 5, 30);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpCard(WidgetTester tester) async {
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
            home: Scaffold(
              body: ListView(children: [ClientCard(clientId: clientId)]),
            ),
          ),
        ),
      );
      await settle(tester);
    }

    testWidgets('shows the active plan remaining sessions and remaining days', (tester) async {
      await pumpCard(tester);
      expect(find.text(AppStrings.fa.remainingDetail(5, 5)), findsOneWidget);
      expect(find.text(AppStrings.fa.remainingDays(30)), findsOneWidget);
      expect(find.byTooltip('متوقف'), findsOneWidget);
    });

    testWidgets('offers an add-plan action', (tester) async {
      await pumpCard(tester);
      expect(find.widgetWithText(OutlinedButton, 'افزودن برنامه'), findsOneWidget);
    });

    testWidgets('no longer shows or changes bonus sessions', (tester) async {
      await pumpCard(tester);
      // The +/− stepper moved to the client profile: a mis-tap on the card used
      // to change the counter without the user ever asking for it.
      expect(find.text('۲ جلسه اضافه'), findsNothing);
      expect(find.byTooltip('جلسه هدیه اضافه شد'), findsNothing);
      expect(find.byTooltip('جلسه هدیه حذف شد'), findsNothing);
      expect((await db.getClient(clientId))!.bonusSessions, 2);
    });

    testWidgets('freeze toggle freezes and activates the plan', (tester) async {
      await pumpCard(tester);
      await tester.tap(find.byTooltip('متوقف'));
      await settle(tester);
      expect((await db.getPlan(planId))!.status, 'frozen');
      expect(find.byTooltip('فعال‌سازی'), findsOneWidget);

      await tester.tap(find.byTooltip('فعال‌سازی'));
      await settle(tester);
      expect((await db.getPlan(planId))!.status, 'active');
      expect(find.byTooltip('متوقف'), findsOneWidget);
    });
  });
}