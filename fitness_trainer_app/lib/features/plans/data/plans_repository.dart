import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as domain;

class PlansRepository {
  final AppDatabase db;
  PlansRepository(this.db);

  Future<List<domain.ClientPlan>> getClientPlans(int clientId) async {
    final rows = await db.getClientPlans(clientId);
    return rows.map((r) => domain.ClientPlan(
      id: r.id,
      clientId: r.clientId,
      templateId: r.templateId,
      startDate: r.startDate,
      sessions: r.sessions,
      days: r.days,
      remaining: r.remaining,
      status: r.status,
      queueOrder: r.queueOrder,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<domain.ClientPlan?> getActivePlan(int clientId) async {
    final row = await db.getActivePlan(clientId);
    if (row == null) return null;
    return domain.ClientPlan(
      id: row.id,
      clientId: row.clientId,
      templateId: row.templateId,
      startDate: row.startDate,
      sessions: row.sessions,
      days: row.days,
      remaining: row.remaining,
      status: row.status,
      queueOrder: row.queueOrder,
      createdAt: row.createdAt,
    );
  }

  Future<domain.ClientPlan?> getFrozenPlan(int clientId) async {
    final row = await db.getFrozenPlan(clientId);
    if (row == null) return null;
    return domain.ClientPlan(
      id: row.id,
      clientId: row.clientId,
      templateId: row.templateId,
      startDate: row.startDate,
      sessions: row.sessions,
      days: row.days,
      remaining: row.remaining,
      status: row.status,
      queueOrder: row.queueOrder,
      createdAt: row.createdAt,
    );
  }

  Future<domain.ClientPlan?> getPlan(int id) async {
    final row = await db.getPlan(id);
    if (row == null) return null;
    return domain.ClientPlan(
      id: row.id,
      clientId: row.clientId,
      templateId: row.templateId,
      startDate: row.startDate,
      sessions: row.sessions,
      days: row.days,
      remaining: row.remaining,
      status: row.status,
      queueOrder: row.queueOrder,
      createdAt: row.createdAt,
    );
  }

  Future<int> insertPlan(ClientPlansCompanion insert) => db.insertPlan(insert);
  Future<bool> updatePlan(ClientPlansCompanion insert) => db.updatePlan(insert);
  Future<int> deletePlan(int id) => db.deletePlan(id);

  Future<List<domain.ClientPlan>> getQueuedPlans() async {
    final rows = await db.getQueuedPlans();
    return rows.map((r) => domain.ClientPlan(
      id: r.id,
      clientId: r.clientId,
      templateId: r.templateId,
      startDate: r.startDate,
      sessions: r.sessions,
      days: r.days,
      remaining: r.remaining,
      status: r.status,
      queueOrder: r.queueOrder,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<List<domain.ClientPlan>> getAllPlans() async {
    final rows = await db.getAllPlans();
    return rows.map((r) => domain.ClientPlan(
      id: r.id,
      clientId: r.clientId,
      templateId: r.templateId,
      startDate: r.startDate,
      sessions: r.sessions,
      days: r.days,
      remaining: r.remaining,
      status: r.status,
      queueOrder: r.queueOrder,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<int> countQueuedPlans(int clientId) => db.countQueuedPlans(clientId);

  /// Plans that were created from a given template (used to propagate
  /// template edits to the plans already in use).
  Future<List<domain.ClientPlan>> getPlansUsingTemplate(int templateId) async {
    final rows = await db.getPlansUsingTemplate(templateId);
    return rows.map((r) => domain.ClientPlan(
      id: r.id,
      clientId: r.clientId,
      templateId: r.templateId,
      startDate: r.startDate,
      sessions: r.sessions,
      days: r.days,
      remaining: r.remaining,
      status: r.status,
      queueOrder: r.queueOrder,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<void> updatePlanRemaining(int planId, int remaining) => db.updatePlanRemaining(planId, remaining);
  Future<void> updatePlanStatus(int planId, String status, {int? queueOrder}) => db.updatePlanStatus(planId, status, queueOrder: queueOrder);
}
