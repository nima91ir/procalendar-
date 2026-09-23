import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:shamsi_date/shamsi_date.dart';
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

    test('deletePlan promotes the next queued plan when the active one is deleted', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final activeId = await plansService.assignPlan(clientId, 1, 5, 30);
      final queuedId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.deletePlan(activeId);
      final active = await db.getPlan(activeId);
      expect(active, isNull);
      final promoted = await db.getPlan(queuedId);
      expect(promoted!.status, 'active');
      expect(promoted.queueOrder, isNull);
      expect(promoted.startDate, isNotNull);
    });

    test('deletePlan leaves the active plan untouched when a queued plan is deleted', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final firstId = await plansService.assignPlan(clientId, 1, 5, 30);
      final queuedId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.deletePlan(queuedId);
      expect((await db.getPlan(firstId))!.status, 'active', reason: 'active plan is not affected');
      final surviving = await db.select(db.clientPlans).get();
      expect(surviving.map((p) => p.status).toSet(), {'active', 'queued'});
      // The only remaining queued plan is still promoted when the active one
      // expires despite the queue-order gap left by the deletion.
      final remainingQueued = surviving.firstWhere((p) => p.status == 'queued');
      final active = surviving.firstWhere((p) => p.status == 'active');
      await plansService.consumeSession(active.id);
      await plansService.consumeSession(active.id);
      await plansService.consumeSession(active.id);
      await plansService.consumeSession(active.id);
      await plansService.consumeSession(active.id);
      expect((await db.getPlan(remainingQueued.id))!.status, 'active');
    });

    test('reactivatePlan restores an expired plan to active with the refunded session', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 2, 30);
      await plansService.consumeSession(planId);
      await plansService.consumeSession(planId);
      expect((await db.getPlan(planId))!.status, 'expired');
      await plansService.reactivatePlan(planId);
      final plan = await db.getPlan(planId);
      expect(plan!.status, 'active');
      expect(plan.remaining, 1);
      expect(plan.queueOrder, isNull);
    });

    test('unfreezePlan changes status back to active', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.freezePlan(planId);
      await plansService.unfreezePlan(planId);
      final plan = await db.getPlan(planId);
      expect(plan!.status, 'active');
    });

    test('assignPlan with price records an income/plan transaction', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 1000000, sharePercent: 30);
      final plan = await db.getPlan(planId);
      expect(plan!.price, 1000000);
      expect(plan.sharePercent, 30);

      await plansService.assignPlan(clientId, 1, 5, 30, price: 500000);
      final transactions = await db.getAllTransactions();
      expect(transactions.length, 2);
      for (final tx in transactions) {
        expect(tx.type, 'income');
        expect(tx.category, 'plan');
        expect(tx.clientId, clientId);
        expect(tx.date, isNotEmpty);
      }
      expect(transactions.map((t) => t.amount).toSet(), {1000000, 500000});
    });

    test('assignPlan with price 0 records no transaction', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      await plansService.assignPlan(clientId, 1, 5, 30);
      expect(await db.getAllTransactions(), isEmpty);
    });

    test('queued plan assignment with price also records income', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      await plansService.assignPlan(clientId, 1, 5, 30, price: 800000);
      await plansService.assignPlan(clientId, 1, 5, 30, price: 900000);
      final transactions = await db.getAllTransactions();
      expect(transactions.length, 2);
      expect(transactions.map((t) => t.amount).toSet(), {800000, 900000});
    });

    test('repository getPlan maps price and sharePercent', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 750000, sharePercent: 40);
      final plan = await plansService.getPlan(planId);
      expect(plan!.price, 750000);
      expect(plan.sharePercent, 40);
    });

    test('planShareDeduction rounds the gym share down', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 99999, sharePercent: 30);
      final plan = await plansService.getPlan(planId);
      expect(plansService.planShareDeduction(plan!), 29999);
    });

    test('assignPlan links the auto-income to the plan id', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 700000);
      final tx = (await db.getAllTransactions()).single;
      expect(tx.planId, planId);
    });

    test('deleting a priced plan removes its auto-income', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 700000);
      expect(await db.getAllTransactions(), hasLength(1));

      await plansService.deletePlan(planId);

      expect(await db.getPlan(planId), isNull);
      expect(await db.getAllTransactions(), isEmpty);
    });

    test('deleting a queued priced plan removes its auto-income', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      await plansService.assignPlan(clientId, 1, 5, 30, price: 400000);
      final queuedId = await plansService.assignPlan(clientId, 1, 5, 30, price: 900000);
      expect(await db.getAllTransactions(), hasLength(2));

      await plansService.deletePlan(queuedId);

      final remaining = await db.getAllTransactions();
      expect(remaining, hasLength(1));
      expect(remaining.single.amount, 400000);
    });

    test('deleting a plan keeps manual (non-plan) transactions', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, price: 700000);
      await db.insertTransaction(TransactionsCompanion.insert(
        clientId: Value(clientId),
        type: 'expense',
        category: 'rent',
        amount: 500000,
        date: '1405/06/01',
      ));
      expect(await db.getAllTransactions(), hasLength(2));

      await plansService.deletePlan(planId);

      final remaining = await db.getAllTransactions();
      expect(remaining, hasLength(1));
      expect(remaining.single.category, 'rent');
    });

    test('deleting a plan removes its attendance history', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      await db.insertAttendance(AttendanceCompanion.insert(
        clientId: clientId,
        planId: Value(planId),
        date: '1405/06/21',
        status: 'present',
      ));
      await plansService.consumeSession(planId);
      expect(await db.getPlanAttendance(planId), hasLength(1));

      await plansService.deletePlan(planId);

      expect(await db.getPlan(planId), isNull);
      expect(await db.getPlanAttendance(planId), isEmpty,
          reason: 'a deleted plan takes its attendance history with it');
    });

    test('deleting one plan keeps the attendance of the remaining plans', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final activeId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.assignPlan(clientId, 1, 5, 30); // queued
      await db.insertAttendance(AttendanceCompanion.insert(
        clientId: clientId,
        planId: Value(activeId),
        date: '1405/06/21',
        status: 'present',
      ));

      final queued = (await db.getClientPlans(clientId)).firstWhere((p) => p.status == 'queued');
      await plansService.deletePlan(queued.id);

      expect(await db.getPlanAttendance(activeId), hasLength(1),
          reason: 'history of the active plan is untouched by another plan delete');
    });

    test('unfreezePlan queues the plan when another plan is already active', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final firstId = await plansService.assignPlan(clientId, 1, 5, 30);
      await plansService.freezePlan(firstId);
      // With the plan frozen, a new assignment is queued, not active.
      final secondId = await plansService.assignPlan(clientId, 1, 5, 30);
      // Reactivate the first so one plan is ACTIVE while the second is still
      // queued; freezing the second then yields "frozen + another active".
      await plansService.unfreezePlan(firstId);
      await plansService.freezePlan(secondId);
      expect((await db.getPlan(firstId))!.status, 'active');
      expect((await db.getPlan(secondId))!.status, 'frozen');

      await plansService.unfreezePlan(secondId);

      final unfrozen = await db.getPlan(secondId);
      expect(unfrozen!.status, 'queued', reason: 'must not create two active plans');
      expect(unfrozen.queueOrder, isNotNull);
      final activeCount =
          (await db.getClientPlans(clientId)).where((p) => p.status == 'active').length;
      expect(activeCount, 1, reason: 'exactly one active plan must remain');
    });

    test('getRemainingDays uses the exact Jalali day difference', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      // A plan that started 10 days ago with a 30-day duration has 20 days
      // left. Picking the start relative to today keeps the assertion exact
      // regardless of which day the test runs.
      final today = Jalali.fromDateTime(DateTime.now());
      final start = today.addDays(-10);
      final startKey =
          '${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')}';
      final planId = await plansService.assignPlan(clientId, 1, 5, 30, startDate: startKey);
      final plan = await plansService.getPlan(planId);
      expect(plansService.getRemainingDays(plan!), 20);
    });

    test('setPlanPrice records income for a legacy unpriced plan', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      // Legacy flow: assigned without a price, so no income row exists yet.
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);
      expect(await db.getAllTransactions(), isEmpty);

      await plansService.setPlanPrice(planId, 500000, 30);

      final plan = await plansService.getPlan(planId);
      expect(plan!.price, 500000);
      expect(plan.sharePercent, 30);
      final txs = await db.getAllTransactions();
      expect(txs, hasLength(1));
      expect(txs.single.type, 'income');
      expect(txs.single.category, 'plan');
      expect(txs.single.amount, 500000);
      expect(txs.single.planId, planId);
      expect(txs.single.clientId, clientId);
    });

    test('setPlanPrice updates the income row when the price changes', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId =
          await plansService.assignPlan(clientId, 1, 5, 30, price: 400000, sharePercent: 10);

      await plansService.setPlanPrice(planId, 600000, 20);

      final plan = await plansService.getPlan(planId);
      expect(plan!.price, 600000);
      expect(plan.sharePercent, 20);
      final txs = await db.getAllTransactions();
      expect(txs, hasLength(1), reason: 'still exactly one income row');
      expect(txs.single.amount, 600000);
    });

    test('setPlanPrice with price 0 removes the recorded income', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId =
          await plansService.assignPlan(clientId, 1, 5, 30, price: 400000, sharePercent: 10);
      expect(await db.getAllTransactions(), hasLength(1));

      await plansService.setPlanPrice(planId, 0, 0);

      final plan = await plansService.getPlan(planId);
      expect(plan!.price, 0);
      expect(plan.sharePercent, 0);
      expect(await db.getAllTransactions(), isEmpty);
    });

    test('setPlanPrice clamps share to 0-100 and price to non-negative', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      final planId = await plansService.assignPlan(clientId, 1, 5, 30);

      await plansService.setPlanPrice(planId, -1000, 250);

      final plan = await plansService.getPlan(planId);
      expect(plan!.price, 0);
      expect(plan.sharePercent, 100);
      expect(await db.getAllTransactions(), isEmpty);
    });

    test('backfillMissingPlanIncome fills priced plans missing income and is idempotent', () async {
      final clientId = (await db.select(db.clients).get()).first.id;
      // A plan priced at assign-time already has its income row ...
      final withIncome = await plansService.assignPlan(clientId, 1, 5, 30, price: 700000);
      // ... while a legacy plan priced later has none.
      final legacy = await plansService.assignPlan(clientId, 1, 5, 30);
      await db.patchPlan(legacy, ClientPlansCompanion(price: Value(500000)));

      await db.backfillMissingPlanIncome();
      await db.backfillMissingPlanIncome();

      final txs = await db.getAllTransactions();
      expect(txs.where((t) => t.planId == withIncome), hasLength(1));
      final legacyTx = txs.where((t) => t.planId == legacy).toList();
      expect(legacyTx, hasLength(1));
      expect(legacyTx.single.amount, 500000);
      expect(legacyTx.single.category, 'plan');
    });
  });
}
