import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/platform/file_saver_provider.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/presentation/widgets/backup_reminder_banner.dart';
import 'package:fitness_trainer_app/features/settings/data/settings_service.dart';

/// The banner is the only backup warning the user ever sees, and it can no
/// longer be dismissed, so these tests pin that it is always on screen, what it
/// says, and that one tap really produces a backup file.
///
/// The locale wiring mirrors the real app: without it `AppStrings.of(context)`
/// resolves to English and the Persian finders below would never match.
void main() {
  late AppDatabase db;
  late SettingsService settings;

  /// Every file the export button produced, as (name, contents).
  ///
  /// The real saver cannot run here: a widget test is on the VM, where
  /// `file_transfer.dart` resolves to the native implementation and
  /// `getApplicationDocumentsDirectory()` has no platform channel to answer it.
  /// The provider is overridden instead, which makes the write observable.
  final savedFiles = <(String, String)>[];

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsService(SettingsRepository(db), db);
    savedFiles.clear();
  });

  tearDown(() => db.close());

  Widget harness() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          textFileSaverProvider.overrideWithValue((name, contents) async {
            savedFiles.add((name, contents));
            return name;
          }),
        ],
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

  testWidgets('is on screen even with a fresh backup, and reports its age', (
    tester,
  ) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -3));

    await tester.pumpWidget(harness());
    await settle(tester);

    // Permanent on purpose: it must not be dismissible-and-forgotten, because
    // the storage it protects is not the app's to control.
    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
    expect(find.text(AppStrings.fa.backupReminderTitle), findsOneWidget);
    expect(find.text(AppStrings.fa.backupReminderWhy), findsOneWidget);
    expect(find.textContaining('۳ روز پیش'), findsOneWidget);
  });

  testWidgets('prompts when the user has never backed up', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
    // Compared against the constant rather than a retyped literal: the Persian
    // text contains ZWNJ characters that are invisible and easy to mistype.
    expect(find.text(AppStrings.fa.lastBackupNever), findsOneWidget);
  });

  testWidgets('shows the age in Persian digits once overdue',
      (tester) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -20));

    await tester.pumpWidget(harness());
    await settle(tester);


    expect(
      find.textContaining('۲۰ روز پیش'),
      findsOneWidget,
    );
    // The explanation stays visible when the backup is old, not just when it is
    // fresh: it is the reason the card exists at all.
    expect(find.text(AppStrings.fa.backupReminderWhy), findsOneWidget);
  });

  testWidgets('cannot be dismissed any more', (tester) async {
    await settings.setLastBackupDate(addJalaliDays(jalaliToday(), -20));

    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
    expect(find.text(AppStrings.fa.backupReminderLater), findsNothing);
    expect(find.textContaining('۲۰ روز پیش'), findsOneWidget);
  });

  testWidgets('one tap exports a backup and records the date', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);
    expect(find.text(AppStrings.fa.lastBackupNever), findsOneWidget);

    await tester.tap(find.text(AppStrings.fa.backupReminderGo));
    await settle(tester);

    // A real file was produced, and the date was recorded because the save
    // reported a name — recording it is what silences the age line.
    expect(savedFiles, hasLength(1));
    expect(savedFiles.single.$1, startsWith('procalendar-backup-'));
    expect(savedFiles.single.$2, contains('"app": "procalendar"'));
    expect(await settings.getLastBackupDate(), jalaliToday());
    expect(find.text(AppStrings.fa.lastBackupNever), findsNothing);
  });

  testWidgets('offers export here, and Settings for the rest', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    // Export is the primary action on the card; restoring a file and the CSV
    // exports still live in Settings.
    expect(
      find.widgetWithText(FilledButton, AppStrings.fa.backupReminderGo),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextButton, AppStrings.fa.settingsTitle),
      findsOneWidget,
    );
  });

  testWidgets('fits a narrow phone without overflowing', (tester) async {
    // The why-text and the two actions are the longest strings on the
    // dashboard, and this app has a history of RenderFlex overflows in dense
    // rows. 320 logical pixels is narrower than any phone this runs on.
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await settle(tester);

    // An overflow is reported as an exception in a widget test, so this fails
    // rather than silently clipping.
    expect(tester.takeException(), isNull);
  });
}
