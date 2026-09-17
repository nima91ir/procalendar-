import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as domain;
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';

class PlansService {
  final PlansRepository repository;
  final AppDatabase db;
  PlansService(this.repository, this.db);

  Future<List<domain.ClientPlan>> getClientPlans(int clientId) => repository.getClientPlans(clientId);
  Future<domain.ClientPlan?> getActivePlan(int clientId) => repository.getActivePlan(clientId);
  Future<domain.ClientPlan?> getFrozenPlan(int clientId) async {
    final plans = await repository.getClientPlans(clientId);
    return plans.where((p) => p.status == 'frozen').firstOrNull;
  }

  Future<int> assignPlan(int clientId, int templateId, int sessions, int days) async {
    final active = await repository.getActivePlan(clientId);
    final frozen = await repository.getFrozenPlan(clientId);
    if (active != null || frozen != null) {
      final queuedCount = await repository.countQueuedPlans(clientId);
      return repository.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: templateId,
        startDate: const Value.absent(),
        sessions: sessions,
        days: days,
        remaining: sessions,
        status: const Value('queued'),
        queueOrder: Value(queuedCount + 1),
      ));
    }
    final today = jalaliToday();
    return repository.insertPlan(ClientPlansCompanion.insert(
      clientId: clientId,
      templateId: templateId,
      startDate: Value(today),
      sessions: sessions,
      days: days,
      remaining: sessions,
      status: const Value('active'),
      queueOrder: const Value.absent(),
    ));
  }

  Future<void> freezePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    await repository.updatePlanStatus(planId, 'frozen');
  }

  Future<void> unfreezePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    await repository.updatePlanStatus(planId, 'active');
  }

  Future<void> deletePlan(int planId) async => repository.deletePlan(planId);

  Future<void> consumeSession(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null || plan.status != 'active') return;
    final newRemaining = plan.remaining - 1;
    if (newRemaining <= 0) {
      await repository.updatePlanStatus(planId, 'expired');
      await _promoteQueuedPlan(plan.clientId);
    } else {
      await repository.updatePlanRemaining(planId, newRemaining);
    }
  }

  Future<void> _promoteQueuedPlan(int clientId) async {
    final queued = await (db.select(db.clientPlans)..where((p) => p.clientId.equals(clientId) & p.status.equals('queued'))..orderBy([(p) => OrderingTerm.asc(p.queueOrder)])).get();
    if (queued.isEmpty) return;
    final next = queued.first;
    final today = jalaliToday();
    await db.updatePlan(ClientPlansCompanion.insert(
      id: Value(next.id),
      clientId: next.clientId,
      templateId: next.templateId,
      sessions: next.sessions,
      days: next.days,
      remaining: next.remaining,
      status: const Value('active'),
      startDate: Value(today),
    ));
    await db.clearPlanQueueOrder(next.id);
  }

  Future<void> updatePlanFromTemplate(int planId, int sessions, int days) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    final remaining = plan.remaining;
    final maxRemaining = (remaining / plan.sessions * sessions).round();
    final updated = domain.ClientPlan(
      id: plan.id,
      clientId: plan.clientId,
      templateId: plan.templateId,
      startDate: plan.startDate,
      sessions: sessions,
      days: days,
      remaining: maxRemaining > sessions ? sessions : maxRemaining,
      status: plan.status,
      queueOrder: plan.queueOrder,
      createdAt: plan.createdAt,
    );
    await repository.updatePlan(ClientPlansCompanion.insert(
      id: Value(updated.id!),
      clientId: updated.clientId,
      templateId: updated.templateId,
      sessions: updated.sessions,
      days: updated.days,
      remaining: updated.remaining,
      status: Value(updated.status),
      startDate: updated.startDate != null ? Value(updated.startDate!) : const Value.absent(),
      queueOrder: updated.queueOrder != null ? Value(updated.queueOrder!) : const Value.absent(),
    ));
  }
}
