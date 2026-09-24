import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/platform/file_saver_provider.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/features/backup/presentation/import_backup_screen.dart';

/// A backup the service accepts (right marker, supported schema) holding a
/// single client whose id differs from the seeded row, so that a wipe is
/// observable in the assertions.
const _incomingBackup = '{"app":"procalendar","schemaVersion":7,"clients":'
    '[{"id":99,"name":"New","contact":null,"note":"","bonusSessions":0,'
    '"createdAt":"1405/06/27"}]}';

/// The screen is pushed from a wrapper route so a successful import has
/// somewhere to pop back to, rather than popping the navigator's only route.
Widget _harness(
  AppDatabase db, {
  required List<String> savedFiles,
  bool failSave = false,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      textFileSaverProvider.overrideWithValue((name, contents) async {
        if (failSave) throw StateError('save failed');
        savedFiles.add(name);
        return name;
      }),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ImportBackupScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Opens the import screen. Buttons are found by icon, so the tests do not
/// depend on localized labels.
Future<void> _open(WidgetTester tester, AppDatabase db, {
  required List<String> savedFiles,
  bool failSave = false,
}) async {
  await tester.pumpWidget(_harness(db, savedFiles: savedFiles, failSave: failSave));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _paste(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), _incomingBackup);
  await tester.pump();
}

/// Drives the destructive path: paste, tap "replace everything", confirm.
Future<void> _replaceAll(WidgetTester tester) async {
  await _paste(tester);
  await tester.tap(find.byIcon(Icons.delete_forever_outlined));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ElevatedButton),
    ),
  );
  await tester.pumpAndSettle();
}

Future<AppDatabase> _seededDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.insertClient(ClientsCompanion.insert(name: 'Old'));
  return db;
}

void main() {
  testWidgets('replace downloads a safety copy before wiping', (tester) async {
    final db = await _seededDb();
    addTearDown(db.close);
    final saved = <String>[];

    await _open(tester, db, savedFiles: saved);
    await _replaceAll(tester);

    expect(saved, hasLength(1));
    expect(saved.single, contains('procalendar-safety-'));
    expect(saved.single, endsWith('.json'));
    // The restore went ahead, so only the incoming client survives.
    final clients = await db.select(db.clients).get();
    expect(clients.map((c) => c.name).toSet(), {'New'});
  });

  testWidgets('an empty database is not exported - nothing is at risk', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final saved = <String>[];

    await _open(tester, db, savedFiles: saved);
    await _replaceAll(tester);

    expect(saved, isEmpty);
    // The restore still happened; there was simply nothing to protect.
    final clients = await db.select(db.clients).get();
    expect(clients.map((c) => c.name).toSet(), {'New'});
  });

  testWidgets('a failed safety copy aborts the restore and keeps the data', (tester) async {
    final db = await _seededDb();
    addTearDown(db.close);
    final saved = <String>[];

    await _open(tester, db, savedFiles: saved, failSave: true);
    await _replaceAll(tester);

    // The whole point of the safety net: no net, no wipe.
    final clients = await db.select(db.clients).get();
    expect(clients.map((c) => c.name).toSet(), {'Old'});
    expect(saved, isEmpty);
  });

  testWidgets('merge never downloads a safety copy and keeps both sides', (tester) async {
    final db = await _seededDb();
    addTearDown(db.close);
    final saved = <String>[];

    await _open(tester, db, savedFiles: saved);
    await _paste(tester);
    await tester.tap(find.byIcon(Icons.merge_type));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    final clients = await db.select(db.clients).get();
    expect(clients.map((c) => c.name).toSet(), {'Old', 'New'});
  });
}
