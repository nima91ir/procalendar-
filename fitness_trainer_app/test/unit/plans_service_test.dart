import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = await Directory.systemTemp.createTemp('fitness_test_');
  final path = p.join(tempDir.path, 'test.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
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

    test('assignPlan creates active plan when no existing plan', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      final plan = await db.getPlan(planId);
      expect(plan, isNotNull);
      expect(plan!.status, 'active');
      expect(plan.remaining, 5);
    });

    test('assignPlan queues plan when active plan exists', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      await plansService.assignPlan(clientId, 1, 5, 30);
      final secondId = await plansService.assignPlan(clientId, 1, 5, 30);
      final second = await db.getPlan(secondId);
      expect(second!.status, 'queued');
      expect(second.queueOrder, 1);
    });

    test('consumeSession expires plan and promotes queued', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      await plansService.assignPlan(clientId, 1, 2, 30);
      await plansService.assignPlan(clientId, 1, 2, 30);
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

    test('freezePlan changes status to frozen', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.freezePlan(planId);
      final plan = await db.getPlan(planId);
      expect(plan!.status, 'frozen');
    });

    test('unfreezePlan changes status back to active', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.freezePlan(planId);
      await plansService.unfreezePlan(planId);
      final plan = await db.getPlan(planId);
      expect(plan!.status, 'active');
    });
  });
}
