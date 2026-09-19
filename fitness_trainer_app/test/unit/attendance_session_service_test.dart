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

    test('adding attendance consumes one session from the active plan', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      final plan = await db.getPlan(planId);
      expect(plan!.remaining, 4);
      expect(plan.status, 'active');
    });

    test('absent also consumes a session', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'absent');
      expect((await db.getPlan(planId))!.remaining, 4);
    });

    test('a second record for the same day consumes a second session', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      await sessionService.addSession(clientId, '1405/06/21', status: 'absent');
      final plan = await db.getPlan(planId);
      expect(plan!.remaining, 3);
      final count = await db.select(db.attendance).get();
      expect(count.length, 2);
      expect((await db.getAttendance(clientId, '1405/06/21'))!.status, 'absent');
    });

    test('last session expires the plan and promotes the queued plan', () async {
      final firstId = await plansService.assignPlan(clientId, 1, 2, 30);
      final queuedId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/20', status: 'present');
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getPlan(firstId))!.status, 'expired');
      final promoted = await db.getPlan(queuedId);
      expect(promoted!.status, 'active');
      expect(promoted.queueOrder, isNull);
    });

    test('consuming a session keeps the plan start date (row-clobber regression)', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      final plan = await db.getPlan(planId);
      expect(plan!.startDate, jalaliToday());
      expect(plan.sessions, 5);
      expect(plan.days, 30);
    });

    test('bonus session is consumed when the client has no plan', () async {
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 2);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 1);
    });

    test('bonus session is consumed when the active plan is exhausted', () async {
      await plansService.assignPlan(clientId, 1, 1, 30);
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 3);
      await sessionService.addSession(clientId, '1405/06/20', status: 'present');
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 2);
    });
  });

  group('Removing attendance returns the session', () {
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

    test('removeLatestSession returns the session to the active plan', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getPlan(planId))!.remaining, 4);
      final removed = await sessionService.removeLatestSession(clientId, '1405/06/21');
      expect(removed, clientId);
      expect((await db.getPlan(planId))!.remaining, 5);
      expect(await db.getAttendance(clientId, '1405/06/21'), isNull);
    });

    test('the record stores the plan the session was consumed from', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getAttendance(clientId, '1405/06/21'))!.planId, planId);
    });

    test('a bonus attendance records a null planId', () async {
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 1);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getAttendance(clientId, '1405/06/21'))!.planId, isNull);
    });

    test('removeLatestSession only removes the latest record of the day', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      await sessionService.addSession(clientId, '1405/06/21', status: 'absent');
      await sessionService.removeLatestSession(clientId, '1405/06/21');
      final remaining = await db.select(db.attendance).get();
      expect(remaining.length, 1);
      expect(remaining.first.status, 'present');
      expect((await db.getPlan(planId))!.remaining, 4);
    });

    test('removeSessionById deletes exactly the tapped record', () async {
      // Two records on one day; delete the *earlier* one by id — the later
      // record must survive.
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      final presentId = (await db.getAttendance(clientId, '1405/06/21'))!.id;
      await sessionService.addSession(clientId, '1405/06/21', status: 'absent');
      final removed = await sessionService.removeSessionById(presentId);
      expect(removed, clientId);
      final remaining = await db.select(db.attendance).get();
      expect(remaining.length, 1);
      expect(remaining.first.status, 'absent');
      expect((await db.getPlan(planId))!.remaining, 4);
    });

    test('removeSessionById refunds the session to the recorded plan, not the current active one', () async {
      // A=2 sessions, then a queued B. Both records come from A; consuming the
      // second expires A and promotes B. Deleting B's record must NOT refund B
      // (B consumed no record); it refunds A, which is no longer active, so the
      // session lands in the active successor B.
      final aId = await plansService.assignPlan(clientId, 1, 2, 30);
      final bId = await plansService.assignPlan(clientId, 1, 3, 30);
      await sessionService.addSession(clientId, '1405/06/20', status: 'present');
      final aLastRecordId = (await db.getAttendance(clientId, '1405/06/20'))!.id;
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      await sessionService.addSession(clientId, '1405/06/22', status: 'present');
      expect((await db.getPlan(aId))!.status, 'expired');
      expect((await db.getPlan(bId))!.remaining, 2, reason: 'third record consumed from promoted B');

      await sessionService.removeSessionById(aLastRecordId);

      expect((await db.getPlan(aId))!.status, 'expired', reason: 'successor is active, expired stays expired');
      expect((await db.getPlan(bId))!.remaining, 3, reason: 'refund lands in the active successor');
    });

    test('removing the record that expired a plan reactivates it when nothing else is active', () async {
      final aId = await plansService.assignPlan(clientId, 1, 2, 30);
      await sessionService.addSession(clientId, '1405/06/20', status: 'present');
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getPlan(aId))!.status, 'expired');
      final expiringId = (await db.getAttendance(clientId, '1405/06/21'))!.id;

      await sessionService.removeSessionById(expiringId);

      final refreshed = await db.getPlan(aId);
      expect(refreshed!.status, 'active');
      expect(refreshed.remaining, 1, reason: 'one record still consumed a session from A');
      expect(refreshed.queueOrder, isNull);
    });

    test('when the active successor is full, the refund becomes a bonus session', () async {
      // A=2, B=2. Both records consume A; the second expires A and promotes B
      // (full). Deleting the first record has nowhere to land: A is expired, B
      // is already full -> the session is restored as a bonus.
      final aId = await plansService.assignPlan(clientId, 1, 2, 30);
      final bId = await plansService.assignPlan(clientId, 1, 2, 30);
      await sessionService.addSession(clientId, '1405/06/20', status: 'present');
      final firstRecordId = (await db.getAttendance(clientId, '1405/06/20'))!.id;
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getPlan(aId))!.status, 'expired');
      expect((await db.getPlan(bId))!.status, 'active');

      await sessionService.removeSessionById(firstRecordId);

      expect((await db.getPlan(aId))!.status, 'expired');
      expect((await db.getPlan(bId))!.remaining, 2);
      expect((await db.getClient(clientId))!.bonusSessions, 1);
    });

    test('removing a record refunds a frozen plan', () async {
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getPlan(planId))!.remaining, 4);
      await plansService.freezePlan(planId);
      await sessionService.removeLatestSession(clientId, '1405/06/21');
      final plan = await db.getPlan(planId);
      expect(plan!.status, 'frozen');
      expect(plan.remaining, 5);
    });

    test('removeSession is a no-op when there is no record for that day', () async {
      expect(await sessionService.removeLatestSession(clientId, '1405/06/21'), isNull);
      expect(await sessionService.removeSessionById(9999), isNull);
      expect(await db.getAttendance(clientId, '1405/06/21'), isNull);
    });

    test('removeLatestSession restores a bonus session when the client has no plan', () async {
      await clientsService.updateClient(clientId, 'Client', bonusSessions: 2);
      await sessionService.addSession(clientId, '1405/06/21', status: 'present');
      expect((await db.getClient(clientId))!.bonusSessions, 1);
      await sessionService.removeLatestSession(clientId, '1405/06/21');
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