import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_session_service.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = await Directory.systemTemp.createTemp('fitness_session_test_');
  final path = p.join(tempDir.path, 'test.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
  group('Attendance session consumption (rules 2 & 4)', () {
    late AppDatabase db;
    late PlansService plansService;
    late ClientsService clientsService;
    late ClientsRepository clientsRepository;
    late AttendanceSessionService sessionService;
    late int clientId;

    setUp(() async {
      db = await createTestDb();
      plansService = PlansService(PlansRepository(db), db);
      clientsRepository = ClientsRepository(db);
      clientsService = ClientsService(clientsRepository);
      sessionService = AttendanceSessionService(
        AttendanceService(AttendanceRepository(db), db),
        plansService,
        clientsRepository,
      );
      await db.insertTemplate(PlanTemplatesCompanion.insert(name: 'T', sessions: 5, days: 30));
      clientId = await clientsService.createClient('Client');
    });

    tearDown(() async {
      await db.close();
    });

    test('marking attendance consumes one session from the active plan', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      final plan = await db.getPlan(planId);
      expect(plan!.remaining, 4);
      expect(plan.status, 'active');
    });

    test('absent also consumes a session', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/21', 'absent');
      expect((await db.getPlan(planId))!.remaining, 4);
    });

    test('re-marking the same day does not consume twice', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      await sessionService.markAttendance(clientId, '1405/06/21', 'absent');
      final plan = await db.getPlan(planId);
      expect(plan!.remaining, 4);
      expect((await db.getAttendance(clientId, '1405/06/21'))!.status, 'absent');
    });

    test('last session expires the plan and promotes the queued plan', () async {
      final firstId = await plansService.assignPlan(clientId, 1, 2, 30);
      final queuedId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/20', 'present');
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      expect((await db.getPlan(firstId))!.status, 'expired');
      final promoted = await db.getPlan(queuedId);
      expect(promoted!.status, 'active');
      expect(promoted.queueOrder, isNull);
    });

    test('consuming a session keeps the plan start date (row-clobber regression)', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      final plan = await db.getPlan(planId);
      expect(plan!.startDate, jalaliToday());
      expect(plan.sessions, 5);
      expect(plan.days, 30);
    });

    test('bonus session is consumed when the client has no plan', () async {
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 2);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 1);
    });

    test('bonus session is consumed when the active plan is exhausted', () async {
      await plansService.assignPlan(clientId, 1, 1, 30);
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 3);
      await sessionService.markAttendance(clientId, '1405/06/20', 'present');
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 2);
    });
  });

  group('Undoing attendance returns the session', () {
    late AppDatabase db;
    late PlansService plansService;
    late ClientsService clientsService;
    late ClientsRepository clientsRepository;
    late AttendanceSessionService sessionService;
    late int clientId;

    setUp(() async {
      db = await createTestDb();
      plansService = PlansService(PlansRepository(db), db);
      clientsRepository = ClientsRepository(db);
      clientsService = ClientsService(clientsRepository);
      sessionService = AttendanceSessionService(
        AttendanceService(AttendanceRepository(db), db),
        plansService,
        clientsRepository,
      );
      await db.insertTemplate(PlanTemplatesCompanion.insert(name: 'T', sessions: 5, days: 30));
      clientId = await clientsService.createClient('Client');
    });

    tearDown(() async {
      await db.close();
    });

    test('undo returns the session to the active plan', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      expect((await db.getPlan(planId))!.remaining, 4);
      final undone = await sessionService.undoAttendance(clientId, '1405/06/21');
      expect(undone, isTrue);
      expect((await db.getPlan(planId))!.remaining, 5);
      expect(await db.getAttendance(clientId, '1405/06/21'), isNull);
    });

    test('undo is a no-op when there is no record for that day', () async {
      final undone = await sessionService.undoAttendance(clientId, '1405/06/21');
      expect(undone, isFalse);
    });

    test('undo returns a bonus session when the client has no plan', () async {
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 2);
      await sessionService.markAttendance(clientId, '1405/06/21', 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 1);
      await sessionService.undoAttendance(clientId, '1405/06/21');
      expect((await db.getClient(clientId))!.bonusSessions, 2);
    });
  });

  group('Template propagation (rule 5)', () {
    late AppDatabase db;
    late PlansService plansService;
    late TemplatesService templatesService;
    late int clientId;

    setUp(() async {
      db = await createTestDb();
      plansService = PlansService(PlansRepository(db), db);
      templatesService = TemplatesService(
        TemplatesRepository(db),
        plansService: plansService,
      );
      final clients = ClientsService(ClientsRepository(db));
      clientId = await clients.createClient('Client');
    });

    tearDown(() async {
      await db.close();
    });

    test('editing a template updates the active plan using it', () async {
      final templateId = await templatesService.createTemplate('T', 5, 30);
      final planId = await plansService.assignPlan(clientId, templateId, 5, 30);
      // Consume one session so the scaling ratio can be verified.
      await plansService.consumeSession(planId);
      await templatesService.updateTemplate(templateId, 'T', 10, 60);
      final plan = await db.getPlan(planId);
      expect(plan!.sessions, 10);
      expect(plan.days, 60);
      // 4 of 5 sessions left -> scaled to 8 of 10.
      expect(plan.remaining, 8);
    });

    test('editing a template leaves queued plans untouched', () async {
      final templateId = await templatesService.createTemplate('T', 5, 30);
      await plansService.assignPlan(clientId, templateId, 5, 30);
      final queuedId = await plansService.assignPlan(clientId, templateId, 5, 30);
      await templatesService.updateTemplate(templateId, 'T', 10, 60);
      final queued = await db.getPlan(queuedId);
      expect(queued!.status, 'queued');
      expect(queued.sessions, 5);
      expect(queued.days, 30);
    });
  });
}