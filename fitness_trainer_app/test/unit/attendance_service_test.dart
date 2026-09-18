import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';
import 'package:fitness_trainer_app/features/dashboard/data/dashboard_service.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = await Directory.systemTemp.createTemp('fitness_test_');
  final path = p.join(tempDir.path, 'test.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
  group('Attendance Service', () {
    late AppDatabase db;
    late AttendanceRepository attendanceRepository;
    late AttendanceService attendanceService;

    setUp(() async {
      db = await createTestDb();
      attendanceRepository = AttendanceRepository(db);
      attendanceService = AttendanceService(attendanceRepository, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('markAttendance creates a new record', () async {
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Test Client'));
      final record = await attendanceService.markAttendance(clientId, '1405/06/21', 'present');
      expect(record, isNotNull);
      expect(record!.clientId, clientId);
      expect(record.date, '1405/06/21');
      expect(record.status, 'present');
    });

    test('markAttendance inserts another record for the same day (multi allowed)', () async {
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Test Client'));
      await attendanceService.markAttendance(clientId, '1405/06/21', 'present');
      final second = await attendanceService.markAttendance(clientId, '1405/06/21', 'absent');
      expect(second, isNotNull);
      expect(second!.status, 'absent');
      final fromDb = await db.getAttendance(clientId, '1405/06/21');
      expect(fromDb, isNotNull);
      expect(fromDb!.id, second.id, reason: 'getAttendance returns the latest record');
      final count = await db.select(db.attendance).get();
      expect(count.length, 2);
    });

    test('getAttendance returns the latest record for a client/day', () async {
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Test Client'));
      await attendanceService.markAttendance(clientId, '1405/06/21', 'present');
      await attendanceService.markAttendance(clientId, '1405/06/21', 'present');
      await attendanceService.markAttendance(clientId, '1405/06/21', 'absent');
      final fromDb = await db.getAttendance(clientId, '1405/06/21');
      expect(fromDb!.status, 'absent');
    });
  });

  group('Plans Service', () {
    late AppDatabase db;
    late PlansRepository plansRepository;
    late PlansService plansService;

    setUp(() async {
      db = await createTestDb();
      plansRepository = PlansRepository(db);
      plansService = PlansService(plansRepository, db);
      await db.insertTemplate(PlanTemplatesCompanion.insert(
        name: 'Test Template',
        sessions: 5,
        days: 30,
      ));
      await db.insertClient(ClientsCompanion.insert(name: 'Test Client'));
    });

    tearDown(() async {
      await db.close();
    });

    test('new active plan uses Jalali start date', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      final plan = await db.getPlan(planId);
      expect(plan, isNotNull);
      expect(plan!.startDate, isNotNull);
      expect(plan.startDate!.length, 10);
      expect(plan.startDate!.contains('/'), isTrue);
    });

    test('queued plan promotion updates start date with Jalali date', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final templateId = (await db.select(db.planTemplates).get()).first.id;
      await plansService.assignPlan(clientId, templateId, 5, 30);
      await plansService.assignPlan(clientId, templateId, 5, 30);
      final plans = await db.getClientPlans(clientId);
      final activePlan = plans.firstWhere((p) => p.status == 'active');
      final queuedPlan = plans.firstWhere((p) => p.status == 'queued');
      for (int i = 0; i < activePlan.remaining; i++) {
        await plansService.consumeSession(activePlan.id);
      }
      final updatedQueued = await db.getPlan(queuedPlan.id);
      expect(updatedQueued!.status, 'active');
      expect(updatedQueued.startDate, isNotNull);
      expect(updatedQueued.startDate!.contains('/'), isTrue);
      expect(updatedQueued.queueOrder, isNull);
    });

    test('plan expires and promotes queued plan', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final templateId = (await db.select(db.planTemplates).get()).first.id;
      await plansService.assignPlan(clientId, templateId, 2, 30);
      await plansService.assignPlan(clientId, templateId, 2, 30);
      final plans = await db.getClientPlans(clientId);
      final activePlan = plans.firstWhere((p) => p.status == 'active');
      final queuedPlan = plans.firstWhere((p) => p.status == 'queued');
      await plansService.consumeSession(activePlan.id);
      await plansService.consumeSession(activePlan.id);
      final expired = await db.getPlan(activePlan.id);
      final promoted = await db.getPlan(queuedPlan.id);
      expect(expired!.status, 'expired');
      expect(promoted!.status, 'active');
    });
  });

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

    test('updateClient rejects empty name', () async {
      final id = await clientsService.createClient('Valid');
      expect(() => clientsService.updateClient(id, ''), throwsA(isA<ArgumentError>()));
    });
  });

  group('Templates Service', () {
    late AppDatabase db;
    late TemplatesRepository templatesRepository;
    late TemplatesService templatesService;

    setUp(() async {
      db = await createTestDb();
      templatesRepository = TemplatesRepository(db);
      templatesService = TemplatesService(templatesRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTemplate inserts template', () async {
      final id = await templatesService.createTemplate('Full Body', 3, 7);
      expect(id, greaterThan(0));
      final template = await db.getTemplate(id);
      expect(template!.name, 'Full Body');
      expect(template.sessions, 3);
      expect(template.days, 7);
    });

    test('createTemplate rejects empty name', () async {
      expect(() => templatesService.createTemplate('', 3, 7), throwsA(isA<ArgumentError>()));
    });

    test('createTemplate rejects non-positive sessions or days', () async {
      expect(() => templatesService.createTemplate('Test', 0, 7), throwsA(isA<ArgumentError>()));
      expect(() => templatesService.createTemplate('Test', 3, 0), throwsA(isA<ArgumentError>()));
    });

    test('updateTemplate modifies existing template', () async {
      final id = await templatesService.createTemplate('Old', 3, 7);
      await templatesService.updateTemplate(id, 'New', 4, 10);
      final template = await db.getTemplate(id);
      expect(template!.name, 'New');
      expect(template.sessions, 4);
      expect(template.days, 10);
    });

    test('deleteTemplate removes template', () async {
      final id = await templatesService.createTemplate('ToDelete', 3, 7);
      expect(await db.getTemplate(id), isNotNull);
      await templatesService.deleteTemplate(id);
      expect(await db.getTemplate(id), isNull);
    });
  });

  group('Tags Service', () {
    late AppDatabase db;
    late TagsRepository tagsRepository;
    late TagsService tagsService;

    setUp(() async {
      db = await createTestDb();
      tagsRepository = TagsRepository(db);
      tagsService = TagsService(tagsRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTag inserts tag', () async {
      final id = await tagsService.createTag('VIP');
      expect(id, greaterThan(0));
      final tag = await db.getTag(id);
      expect(tag!.name, 'VIP');
    });

    test('createTag rejects empty name', () async {
      expect(() => tagsService.createTag(''), throwsA(isA<ArgumentError>()));
    });

    test('updateTag modifies existing tag', () async {
      final id = await tagsService.createTag('Old', emoji: '⭐');
      await tagsService.updateTag(id, 'New', emoji: '🌟', color: 0xFFFF0000);
      final tag = await db.getTag(id);
      expect(tag!.name, 'New');
      expect(tag.emoji, '🌟');
      expect(tag.color, 0xFFFF0000);
    });

    test('deleteTag removes tag', () async {
      final id = await tagsService.createTag('ToDelete');
      expect(await db.getTag(id), isNotNull);
      await tagsService.deleteTag(id);
      expect(await db.getTag(id), isNull);
    });

    test('assignTagToClient and removeTagFromClient', () async {
      final tagId = await tagsService.createTag('VIP');
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Client'));
      await tagsService.assignTagToClient(clientId, tagId);
      final clientTags = await db.getClientTagIds(clientId);
      expect(clientTags, [tagId]);
      await tagsService.removeTagFromClient(clientId, tagId);
      final afterRemove = await db.getClientTagIds(clientId);
      expect(afterRemove, isEmpty);
    });

    test('countClientsWithTag returns correct count', () async {
      final tagId = await tagsService.createTag('VIP');
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Client'));
      await tagsService.assignTagToClient(clientId, tagId);
      expect(await tagsService.countClientsWithTag(tagId), 1);
    });
  });

  group('Dashboard Service', () {
    late AppDatabase db;
    late DashboardService dashboardService;
    late AttendanceService attendanceService;

    setUp(() async {
      db = await createTestDb();
      dashboardService = DashboardService(db);
      final attendanceRepository = AttendanceRepository(db);
      attendanceService = AttendanceService(attendanceRepository, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getTodayAttendance returns empty map when no attendance', () async {
      final result = await dashboardService.getTodayAttendance();
      expect(result, isEmpty);
    });

    test('getTodayAttendance counts multiple records per client and status', () async {
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Test Client'));
      final otherId = await db.insertClient(ClientsCompanion.insert(name: 'Other Client'));
      final today = jalaliToday();
      await attendanceService.markAttendance(clientId, today, 'present');
      await attendanceService.markAttendance(clientId, today, 'present');
      await attendanceService.markAttendance(clientId, today, 'absent');
      await attendanceService.markAttendance(otherId, today, 'absent');
      final result = await dashboardService.getTodayAttendance();
      expect(result[clientId], {'present': 2, 'absent': 1});
      expect(result[otherId], {'absent': 1});
      expect(result.length, 2);
    });
  });
}
