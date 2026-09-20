import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_models.dart';

AppDatabase createDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<void> seed(AppDatabase db) async {
  final clientId = await db.insertClient(ClientsCompanion.insert(
    name: 'سارا محمدی',
    contact: const Value('09120000000'),
    note: const Value('VIP'),
    bonusSessions: const Value(2),
    createdAt: const Value('1405/06/27'),
  ));
  final tagId = await db.insertTag(TagsCompanion.insert(
    name: 'ویژه',
    emoji: const Value('⭐'),
  ));
  await db.assignTagToClient(clientId, tagId);
  final templateId = await db.insertTemplate(PlanTemplatesCompanion.insert(
    name: 'قدرت',
    sessions: 8,
    days: 30,
  ));
  await db.insertPlan(ClientPlansCompanion.insert(
    clientId: clientId,
    templateId: templateId,
    sessions: 8,
    days: 30,
    remaining: 5,
    status: const Value('active'),
    startDate: const Value('1405/06/01'),
  ));
  await db.insertAttendance(AttendanceCompanion.insert(
    clientId: clientId,
    date: '1405/06/27',
    status: 'present',
  ));
  await db.insertTransaction(TransactionsCompanion.insert(
    clientId: Value(clientId),
    type: 'income',
    category: 'plan',
    amount: 300000,
    date: '1405/06/27',
    note: const Value('جلسه اول'),
  ));
  await db.into(db.appSettings).insert(
        AppSettingsCompanion.insert(key: 'trainer_name', value: 'نیما'),
      );
}

void main() {
  // Backup tests hold source and target databases open at the same time
  // (each with its own in-memory executor) to verify restore behaviour.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('BackupService JSON', () {
    test('exportJson emits marker, schema version and every table', () async {
      final db = createDb();
      await seed(db);
      final json = await BackupService(db).exportJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['app'], 'procalendar');
      expect(decoded['schemaVersion'], 7);
      expect((decoded['clients'] as List).length, 1);
      expect((decoded['tags'] as List).length, 1);
      expect((decoded['clientTags'] as List).length, 1);
      expect((decoded['templates'] as List).length, 1);
      expect((decoded['plans'] as List).length, 1);
      expect((decoded['attendance'] as List).length, 1);
      expect((decoded['transactions'] as List).length, 1);
      expect((decoded['settings'] as List).length, 1);
      await db.close();
    });

    test('previewCounts reports rows without writing', () async {
      final source = createDb();
      await seed(source);
      final json = await BackupService(source).exportJson();

      final target = createDb();
      final counts = BackupService(target).previewCounts(json);
      expect(counts.clients, 1);
      expect(counts.plans, 1);
      expect(counts.attendance, 1);
      expect(await target.getAllClients(), isEmpty);

      await source.close();
      await target.close();
    });

    test('replace wipes existing data and restores the backup', () async {
      final source = createDb();
      await seed(source);
      final json = await BackupService(source).exportJson();

      final target = createDb();
      await BackupService(target).importJson(
        '{"app":"procalendar","schemaVersion":3,"clients":[]}',
        mode: BackupImportMode.replace,
      );
      expect(await target.getAllClients(), isEmpty);

      final result = await BackupService(target).importJson(
        json,
        mode: BackupImportMode.replace,
      );
      expect(result.mode, BackupImportMode.replace);
      expect(result.added.clients, 1);
      final clients = await target.getAllClients();
      expect(clients.single.name, 'سارا محمدی');
      expect(clients.single.bonusSessions, 2);
      expect((await target.getAllAttendance()).single.date, '1405/06/27');
      expect((await target.getAllTransactions()).single.amount, 300000);
      expect((await target.getAllSettings()).single.key, 'trainer_name');

      await source.close();
      await target.close();
    });

    test('merge adds missing rows into an empty database', () async {
      final source = createDb();
      await seed(source);
      final json = await BackupService(source).exportJson();

      final target = createDb();
      final result = await BackupService(target).importJson(
        json,
        mode: BackupImportMode.merge,
      );
      expect(result.added.total, result.total.total);
      expect((await target.getAllClients()).single.name, 'سارا محمدی');

      await source.close();
      await target.close();
    });

    test('merge never overwrites an existing conflicting id', () async {
      final source = createDb();
      await seed(source);
      final json = await BackupService(source).exportJson();

      final target = createDb();
      await target.insertClient(ClientsCompanion.insert(name: 'OTHER'));

      final result = await BackupService(target).importJson(
        json,
        mode: BackupImportMode.merge,
      );
      expect(result.added.clients, 0);
      expect((await target.getAllClients()).single.name, 'OTHER');

      await source.close();
      await target.close();
    });

    test('rejects malformed or newer backups', () async {
      final db = createDb();
      final service = BackupService(db);
      expect(() => service.previewCounts('not json'), throwsA(isA<FormatException>()));
      expect(
        () => service.previewCounts('{"app":"other","schemaVersion":1}'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.previewCounts('{"app":"procalendar","schemaVersion":99}'),
        throwsA(isA<FormatException>()),
      );
      await db.close();
    });
  });

  group('BackupService CSV', () {
    test('quotes separators, quotes and newlines and prefixes a BOM', () async {
      final db = createDb();
      await db.insertClient(ClientsCompanion.insert(
        name: 'Ali, "the" trainer\nnewline',
        note: const Value(''),
      ));
      final csv = await BackupService(db).exportClientsCsv();

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv.contains('"Ali, ""the"" trainer\nnewline"'), isTrue);
      await db.close();
    });

    test('plans CSV resolves client and template names', () async {
      final db = createDb();
      await seed(db);
      final csv = await BackupService(db).exportPlansCsv();
      expect(csv.contains('سارا محمدی'), isTrue);
      expect(csv.contains('قدرت'), isTrue);
      await db.close();
    });

    test('transactions CSV resolves client name and amount', () async {
      final db = createDb();
      await seed(db);
      final csv = await BackupService(db).exportTransactionsCsv();
      expect(csv.contains('سارا محمدی'), isTrue);
      expect(csv.contains('300000'), isTrue);
      expect(csv.contains('income'), isTrue);
      await db.close();
    });
  });

  test('timestampSuffix is compact and sortable', () {
    final suffix = BackupService.timestampSuffix(DateTime(2026, 9, 18, 15, 3));
    expect(suffix, '20260918-1503');
  });
}
