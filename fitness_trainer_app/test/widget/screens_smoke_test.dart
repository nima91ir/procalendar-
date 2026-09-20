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
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/main.dart';

/// Renders every route in the real router, in both themes, and fails on any
/// exception raised while building or laying out a screen.
///
/// This is the net that was missing: `flutter analyze` and the service unit
/// tests were green while the client detail screen was throwing
/// "RenderFlex children have non-zero flex but incoming width constraints are
/// unbounded" and rendering blank.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Mirrors the real app's locale wiring so `AppStrings.of(context)` resolves
/// to Persian (the app's default language) during widget tests.
Widget buildHarness(
  AppDatabase db, {
  ThemeData? theme,
  Widget? home,
  String? initialRoute,
}) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: theme,
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

class Fixture {
  final AppDatabase db;
  final int clientId;
  final int templateId;

  Fixture({required this.db, required this.clientId, required this.templateId});
}

Future<Fixture> buildFixture() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final plans = PlansService(PlansRepository(db), db);
  final templates = TemplatesService(TemplatesRepository(db), plansService: plans);
  final clients = ClientsService(ClientsRepository(db));
  final tags = TagsService(TagsRepository(db));

  final clientId = await clients.createClient('سارا محمدی', contact: '09120000000', bonusSessions: 2);
  final templateId = await templates.createTemplate('قالب تست', 8, 30);
  await plans.assignPlan(clientId, templateId, 8, 30);
  final tagId = await tags.createTag('ویژه', emoji: '⭐');
  await tags.assignTagToClient(clientId, tagId);
  return Fixture(db: db, clientId: clientId, templateId: templateId);
}

void main() {
  final themes = <String, ThemeData>{
    'light': AppTheme.light,
    'dark': AppTheme.dark,
  };

  for (final entry in themes.entries) {
    group('Screen render smoke (${entry.key})', () {
      late Fixture fixture;

      setUp(() async {
        fixture = await buildFixture();
      });

      tearDown(() async {
        await fixture.db.close();
      });

      final primaryRoutes = <String, String>{
        '/dashboard': 'تقویم حرفه‌ای',
        '/clients': 'مشتریان',
        '/templates': 'قالب‌های برنامه',
        '/accounting': 'حسابداری',
        '/settings': 'تنظیمات',
      };

      const tabIcons = <String, IconData>{
        '/clients': Icons.people_outline,
        '/templates': Icons.calendar_today_outlined,
        '/accounting': Icons.account_balance_wallet_outlined,
        '/settings': Icons.settings_outlined,
      };

      primaryRoutes.forEach((route, expectedText) {
        testWidgets('renders $route', (tester) async {
          await tester.pumpWidget(
            buildHarness(fixture.db, theme: entry.value, home: const MainShell()),
          );
          await settle(tester);

          if (route != '/dashboard') {
            final bottomNav = find.byType(NavigationBar);
            final navIcon = find.descendant(of: bottomNav, matching: find.byIcon(tabIcons[route]!));
            await tester.tap(navIcon);
            await tester.pump();
            await settle(tester);
          }

          expect(tester.takeException(), isNull);
          expect(find.text(expectedText), findsWidgets);
        });
      });

      final subRoutes = <String, String>{
        '/clients/add': 'افزودن مشتری',
        '/templates/add': 'قالب جدید',
        '/tags': 'برچسب‌ها',
      };

      subRoutes.forEach((route, expectedText) {
        testWidgets('renders $route', (tester) async {
          await tester.pumpWidget(
            buildHarness(fixture.db, theme: entry.value, initialRoute: route),
          );
          await settle(tester);

          expect(tester.takeException(), isNull);
          expect(find.text(expectedText), findsWidgets);
        });
      });

      testWidgets('renders /clients/detail/:id', (tester) async {
        await tester.pumpWidget(
          buildHarness(fixture.db, theme: entry.value, initialRoute: '/clients/detail/${fixture.clientId}'),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('سارا محمدی'), findsWidgets);
        expect(find.text('اطلاعات تماس'), findsOneWidget);
        expect(find.text('برنامه‌ها'), findsOneWidget);
      });

      testWidgets('renders /clients/edit/:id', (tester) async {
        await tester.pumpWidget(
          buildHarness(fixture.db, theme: entry.value, initialRoute: '/clients/edit/${fixture.clientId}'),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('ویرایش مشتری'), findsOneWidget);
      });

      testWidgets('renders /templates/edit/:id', (tester) async {
        await tester.pumpWidget(
          buildHarness(fixture.db, theme: entry.value, initialRoute: '/templates/edit/${fixture.templateId}'),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('ویرایش قالب'), findsOneWidget);
      });

      testWidgets('renders /attendance/:id', (tester) async {
        await tester.pumpWidget(
          buildHarness(fixture.db, theme: entry.value, initialRoute: '/attendance/${fixture.clientId}'),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('وضعیت جلسات'), findsOneWidget);
      });

      // Regression: the plan cards in the client detail navigate to
      // `/attendance/:id/:planId`, which used to fall into the "page not
      // found" route because the router parsed the whole tail as one id.
      testWidgets('renders /attendance/:id/:planId (plan-scoped)', (tester) async {
        final plans = await fixture.db.getClientPlans(fixture.clientId);
        final planId = plans.first.id;
        await tester.pumpWidget(
          buildHarness(
            fixture.db,
            theme: entry.value,
            initialRoute: '/attendance/${fixture.clientId}/$planId',
          ),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('وضعیت جلسات'), findsOneWidget);
      });

      testWidgets('renders /add-plan/:id', (tester) async {
        await tester.pumpWidget(
          buildHarness(fixture.db, theme: entry.value, initialRoute: '/add-plan/${fixture.clientId}'),
        );
        await settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('انتخاب قالب برنامه'), findsOneWidget);
      });
    });
  }
}