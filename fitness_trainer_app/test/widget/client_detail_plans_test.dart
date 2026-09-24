import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/presentation/client_detail_screen.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';

/// The profile owns what the client card gave up: the bonus-session stepper and
/// a real add-plan button. The plan card must state the activation date, the
/// remaining sessions and the remaining days.
void main() {
  group('Client profile', () {
    late AppDatabase db;
    late int clientId;

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final templates = TemplatesService(TemplatesRepository(db));
      final plans = PlansService(PlansRepository(db), db);
      final clients = ClientsService(ClientsRepository(db));
      final templateId = await templates.createTemplate('T', 8, 30);
      clientId = await clients.createClient('سارا', bonusSessions: 2);
      await plans.assignPlan(clientId, templateId, 8, 30);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpDetail(WidgetTester tester) async {
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
            theme: AppTheme.light,
            home: ClientDetailScreen(clientId: clientId),
          ),
        ),
      );
      await settle(tester);
    }

    /// The plan card sits below the fold on the default test window.
    Future<void> scrollToPlans(WidgetTester tester) async {
      await tester.drag(find.byType(ListView), const Offset(0, -320));
      await settle(tester);
    }

    testWidgets('offers a real add-plan button', (tester) async {
      await pumpDetail(tester);
      expect(find.widgetWithText(FilledButton, AppStrings.fa.addPlan), findsOneWidget);
    });

    testWidgets('bonus stepper lives here and persists', (tester) async {
      await pumpDetail(tester);
      // The hero chip shows the same text, so match on the tooltips instead.
      expect(find.byTooltip(AppStrings.fa.bonusAdded), findsOneWidget);
      expect(find.byTooltip(AppStrings.fa.bonusRemoved), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.fa.bonusAdded));
      await settle(tester);
      expect((await db.getClient(clientId))!.bonusSessions, 3);
      expect(find.text(AppStrings.fa.clientsWithBonus(3)), findsWidgets);

      await tester.tap(find.byTooltip(AppStrings.fa.bonusRemoved));
      await settle(tester);
      expect((await db.getClient(clientId))!.bonusSessions, 2);
    });

    testWidgets('plan card shows activation date, remaining sessions and days', (tester) async {
      await pumpDetail(tester);
      await scrollToPlans(tester);

      expect(find.text(AppStrings.fa.remainingSessions(8)), findsOneWidget);
      expect(find.text(AppStrings.fa.remainingDays(30)), findsOneWidget);
      expect(find.text(formatDateShort(jalaliToday(), 'fa')), findsOneWidget);
      expect(find.text(AppStrings.fa.remainingDetail(8, 8)), findsOneWidget);
    });
  });
}
