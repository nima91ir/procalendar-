import 'package:drift/drift.dart';
import 'package:shamsi_date/shamsi_date.dart';
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
  Future<domain.ClientPlan?> getPlan(int planId) => repository.getPlan(planId);
  Future<domain.ClientPlan?> getFrozenPlan(int clientId) async {
    final plans = await repository.getClientPlans(clientId);
    return plans.where((p) => p.status == 'frozen').firstOrNull;
  }

  /// Assigns a plan from a template.
  ///
  /// [startDate] is a Jalali `yyyy/MM/dd` key chosen in the UI. It is stored
  /// exactly as picked. When the client already has an active/frozen plan the
  /// new plan is queued regardless — its real start date is stamped (today)
  /// at promotion time, because queuing implies "starts when the current plan
  /// finishes".
  Future<int> assignPlan(int clientId, int templateId, int sessions, int days, {String? startDate}) async {
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
      startDate: Value(startDate ?? today),
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

  /// Plans created from [templateId], used to propagate template edits.
  Future<List<domain.ClientPlan>> getPlansUsingTemplate(int templateId) =>
      repository.getPlansUsingTemplate(templateId);

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

  /// Gives one session back to a plan (used when an attendance record is
  /// deleted/undone). Capped at the plan's total session count.
  Future<void> restoreSession(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null || plan.status == 'queued') return;
    final restored = plan.remaining + 1;
    if (restored <= plan.sessions) {
      await repository.updatePlanRemaining(planId, restored);
    }
  }

  Future<void> _promoteQueuedPlan(int clientId) async {
    final queued = await (db.select(db.clientPlans)..where((p) => p.clientId.equals(clientId) & p.status.equals('queued'))..orderBy([(p) => OrderingTerm.asc(p.queueOrder)])).get();
    if (queued.isEmpty) return;
    final next = queued.first;
    // Partial update so the rest of the row (created_at, days, ...) survives
    // the promotion; the previous full-row replace reset those columns.
    await db.patchPlan(
      next.id,
      ClientPlansCompanion(
        status: const Value('active'),
        startDate: Value(jalaliToday()),
        queueOrder: const Value(null),
      ),
    );
  }

  Future<void> updatePlanFromTemplate(int planId, int sessions, int days) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    if (sessions <= 0 || days <= 0) return;
    // Keep the consumed/total ratio so an in-progress plan stays consistent.
    final maxRemaining = plan.sessions <= 0 ? sessions : (plan.remaining / plan.sessions * sessions).round();
    final remaining = maxRemaining > sessions ? sessions : maxRemaining;
    await db.patchPlan(
      planId,
      ClientPlansCompanion(
        sessions: Value(sessions),
        days: Value(days),
        remaining: Value(remaining),
      ),
    );
  }

  /// Calculates remaining days for an active/frozen plan based on its
  /// [startDate] and [days] fields vs today. Returns `null` for queued plans
  /// or plans without a start date.
  int? getRemainingDays(domain.ClientPlan plan) {
    if (plan.startDate == null || plan.startDate!.isEmpty) return null;
    if (plan.status != 'active' && plan.status != 'frozen') return null;
    final parts = plan.startDate!.split('/');
    if (parts.length != 3) return null;
    final start = Jalali(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final end = start.addDays(plan.days);
    final today = Jalali.fromDateTime(DateTime.now());
    final endDateTime = DateTime(end.year, end.month, end.day);
    final todayDateTime = DateTime(today.year, today.month, today.day);
    final diff = endDateTime.difference(todayDateTime).inDays;
    return diff > 0 ? diff : 0;
  }
}
