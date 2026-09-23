import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = Directory.systemTemp;
  final path = p.join(tempDir.path, 'test_${DateTime.now().millisecondsSinceEpoch}.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
  group('Clients Service', () {
    late AppDatabase db;
    late ClientsRepository clientsRepository;
    late ClientsService clientsService;

    setUp(() async {
      db = await createTestDb();
      clientsRepository = ClientsRepository(db);
      clientsService = ClientsService(clientsRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('createClient rejects empty name', () async {
      expect(() => clientsService.createClient(''), throwsA(isA<ArgumentError>()));
      expect(() => clientsService.createClient('   '), throwsA(isA<ArgumentError>()));
    });

    test('createClient inserts client with defaults', () async {
      final id = await clientsService.createClient('Ali');
      expect(id, greaterThan(0));
      final client = await db.getClient(id);
      expect(client, isNotNull);
      expect(client!.name, 'Ali');
      expect(client.note, '');
      expect(client.bonusSessions, 0);
    });

    test('createClient inserts client with contact and bonus sessions', () async {
      final id = await clientsService.createClient('Sara', contact: '0912', note: 'VIP', bonusSessions: 3);
      final client = await db.getClient(id);
      expect(client!.contact, '0912');
      expect(client.note, 'VIP');
      expect(client.bonusSessions, 3);
    });

    test('deleteClient removes client from database', () async {
      final id = await clientsService.createClient('ToDelete');
      expect(await db.getClient(id), isNotNull);
      await clientsService.deleteClient(id);
      expect(await db.getClient(id), isNull);
    });

    test('deleteClient cascade removes plans, attendance, ledger rows and tags', () async {
      final clientId = await clientsService.createClient('CascadeFull');
      await db.insertTemplate(PlanTemplatesCompanion.insert(
        name: 'Test Template',
        sessions: 5,
        days: 30,
      ));
      final planId = await db.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: 1,
        sessions: 5,
        days: 30,
        remaining: 5,
        status: const Value('active'),
      ));
      await db.insertAttendance(AttendanceCompanion.insert(
        clientId: clientId,
        planId: Value(planId),
        date: '1405/06/21',
        status: 'present',
      ));
      final tagId = await db.insertTag(TagsCompanion.insert(name: 'تست'));
      await db.assignTagToClient(clientId, tagId);
      await db.insertTransaction(TransactionsCompanion.insert(
        clientId: Value(clientId),
        type: 'income',
        category: 'plan',
        amount: 1000000,
        date: '1405/06/21',
      ));

      await clientsService.deleteClient(clientId);

      expect(await db.getClient(clientId), isNull);
      expect(await db.getClientPlans(clientId), isEmpty);
      expect(await db.getClientAttendance(clientId), isEmpty);
      expect(await db.getClientTransactions(clientId), isEmpty);
      expect(await db.getClientTagIds(clientId), isEmpty);
    });

    test('deleteClient cascade works without FK enforcement (web-like)', () async {
      // SQLite web builds never run `PRAGMA foreign_keys = ON`, so cascades
      // must not be relied on — the explicit deletes have to do the work.
      final webDb = AppDatabase.forTesting(NativeDatabase.memory());
      final webRepository = ClientsRepository(webDb);
      final webService = ClientsService(webRepository);
      final clientId = await webService.createClient('WebClient');
      await webDb.insertTemplate(PlanTemplatesCompanion.insert(
        name: 'Test Template',
        sessions: 5,
        days: 30,
      ));
      final planId = await webDb.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: 1,
        sessions: 5,
        days: 30,
        remaining: 5,
        status: const Value('active'),
      ));
      await webDb.insertAttendance(AttendanceCompanion.insert(
        clientId: clientId,
        planId: Value(planId),
        date: '1405/06/21',
        status: 'present',
      ));
      await webDb.insertTransaction(TransactionsCompanion.insert(
        clientId: Value(clientId),
        type: 'income',
        category: 'plan',
        amount: 1000000,
        date: '1405/06/21',
      ));

      await webService.deleteClient(clientId);

      expect(await webDb.getClient(clientId), isNull);
      expect(await webDb.select(webDb.clientPlans).get(), isEmpty,
          reason: 'the orphaned plan must be deleted even with FK off');
      expect(await webDb.select(webDb.attendance).get(), isEmpty);
      expect(await webDb.select(webDb.transactions).get(), isEmpty,
          reason: 'the orphaned ledger row must be deleted even with FK off');
      await webDb.close();
    });

test('deleteClient cascades plans and attendance', () async {
      final clientId = await clientsService.createClient('Cascade');
      await db.insertTemplate(PlanTemplatesCompanion.insert(
        name: 'Test Template',
        sessions: 5,
        days: 30,
      ));
      await db.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: 1,
        sessions: 5,
        days: 30,
        remaining: 5,
        status: const Value('active'),
      ));
      await db.insertAttendance(AttendanceCompanion.insert(
        clientId: clientId,
        date: '1405/06/21',
        status: 'present',
      ));
      await clientsService.deleteClient(clientId);
      final plans = await db.getClientPlans(clientId);
      expect(plans, isEmpty);
      final attendance = await db.getClientAttendance(clientId);
      expect(attendance, isEmpty);
    });

    test('searchClients returns matching clients', () async {
      await clientsService.createClient('Ali Ahmadi');
      await clientsService.createClient('Sara Mohammadi');
      final results = await clientsService.searchClients('Ali');
      expect(results.length, 1);
      expect(results.first.name, 'Ali Ahmadi');
    });

    test('updateClient modifies existing client', () async {
      final id = await clientsService.createClient('Old Name');
      await clientsService.updateClient(id, 'New Name', contact: '0999', note: 'Updated', bonusSessions: 2);
      final client = await db.getClient(id);
      expect(client!.name, 'New Name');
      expect(client.contact, '0999');
      expect(client.note, 'Updated');
      expect(client.bonusSessions, 2);
    });

    test('createClient stamps today and updates preserve it (clone regression)', () async {
      final id = await clientsService.createClient('Stamped');
      expect((await db.getClient(id))!.createdAt, jalaliToday());
      await clientsService.updateClient(id, 'Stamped 2', bonusSessions: 4);
      expect((await db.getClient(id))!.createdAt, jalaliToday(), reason: 'updateClient must not wipe createdAt');
      await clientsRepository.updateClientBonus(id, 1);
      expect((await db.getClient(id))!.createdAt, jalaliToday(), reason: 'updateClientBonus must not wipe createdAt');
    });

    test('updateClient rejects empty name', () async {
      final id = await clientsService.createClient('Valid');
      expect(() => clientsService.updateClient(id, ''), throwsA(isA<ArgumentError>()));
    });
  });
}
