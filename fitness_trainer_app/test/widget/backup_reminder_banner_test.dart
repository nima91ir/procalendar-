import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/backup/presentation/widgets/backup_reminder_banner.dart';
import 'package:fitness_trainer_app/features/settings/data/settings_service.dart';

/// The banner is the only backup warning the user ever sees, so these tests pin
/// when it appears, what it says, and that "later" actually silences it.
///
/// The locale wiring mirrors the real app: without it `AppStrings.of(context)`
/// resolves to English and the Persian finders below would never match.
void main() {
  late AppDatabase db;
  late SettingsService settings;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsService(SettingsRepository(db), db);
  });

  tearDown(() => db.close());

  Widget harness() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: BackupReminderBanner()),
        ),
      );

  /// The provider reads the database asynchronously; pump until it settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('renders nothing when a recent backup exists', (tester) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -3));

    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsNothing);
  });

  testWidgets('renders nothing right up to the interval boundary',
      (tester) async {
    await settings.setLastBackupDate(
      addJalaliDays(jalaliToday(), -(BackupReminder.intervalDays - 1)),
    );

    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsNothing);
  });

  testWidgets('prompts when the user has never backed up', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
    // Compared against the constant rather than a retyped literal: the Persian
    // text contains ZWNJ characters that are invisible and easy to mistype.
    expect(find.text(AppStrings.fa.lastBackupNever), findsOneWidget);
  });

  testWidgets('prompts once the backup is overdue, in Persian digits',
      (tester) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -20));

    await tester.pumpWidget(harness());
    await settle(tester);


    expect(
      find.text('۲۰ روز از آخرین پشتیبان‌گیری گذشته است'),
      findsOneWidget,
    );
    expect(find.text('بعداً'), findsOneWidget);
  });

  testWidgets('"later" snoozes the banner out of sight', (tester) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -20));

    await tester.pumpWidget(harness());
    await settle(tester);
    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);

    await tester.tap(find.text('بعداً'));
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsNothing);
    expect(
      await settings.getBackupSnoozeUntil(),
      addJalaliDays(jalaliToday(), BackupReminder.snoozeDays),
    );
  });
}
