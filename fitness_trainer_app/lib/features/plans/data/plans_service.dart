import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as domain;
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/plan_dates.dart';

class PlansService {
  final PlansRepository repository;
  final AppDatabase db;
  PlansService(this.repository, this.db);

  /// Reads the client's plans after expiring any plan whose duration has run
  /// out. Expiry used to depend on sessions alone, so a plan whose `days` had
  /// elapsed stayed `active` forever.
  Future<List<domain.ClientPlan>> getClientPlans(int clientId) async {
    await expireElapsedPlans(clientId: clientId);
    return repository.getClientPlans(clientId);
  }

  /// Every plan across all clients, after the same expiry sweep — the
  /// accounting per-plan section and the dashboard read from here.
  Future<List<domain.ClientPlan>> getAllPlans() async {
    await expireElapsedPlans();
    return repository.getAllPlans();
  }

  /// The client's active plan, after the expiry sweep, so attendance can never
  /// consume a session from a plan that has already run out of days.
  Future<domain.ClientPlan?> getActivePlan(int clientId) async {
    await expireElapsedPlans(clientId: clientId);
    return repository.getActivePlan(clientId);
  }
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
  Future<int> assignPlan(int clientId, int templateId, int sessions, int days, {int price = 0, int sharePercent = 0, String? startDate}) async {
    final active = await repository.getActivePlan(clientId);
    final frozen = await repository.getFrozenPlan(clientId);
    late int planId;
    if (active != null || frozen != null) {
      final queuedCount = await repository.countQueuedPlans(clientId);
      planId = await repository.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: templateId,
        startDate: const Value.absent(),
        sessions: sessions,
        days: days,
        price: Value(price),
        sharePercent: Value(sharePercent),
        remaining: sessions,
        status: const Value('queued'),
        queueOrder: Value(queuedCount + 1),
      ));
    } else {
      final today = jalaliToday();
      planId = await repository.insertPlan(ClientPlansCompanion.insert(
        clientId: clientId,
        templateId: templateId,
        startDate: Value(startDate ?? today),
        sessions: sessions,
        days: days,
        price: Value(price),
        sharePercent: Value(sharePercent),
        remaining: sessions,
        status: const Value('active'),
        queueOrder: const Value.absent(),
      ));
    }
    if (price > 0) {
      await db.insertTransaction(TransactionsCompanion(
        clientId: Value(clientId),
        planId: Value(planId),
        type: const Value('income'),
        category: const Value('plan'),
        amount: Value(price),
        date: Value(jalaliToday()),
        note: const Value(''),
      ));
    }
    return planId;
  }

  Future<void> freezePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    await repository.updatePlanStatus(planId, 'frozen');
  }

  Future<void> unfreezePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    // Exactly one active plan per client: reactivating a frozen plan while
    // another plan is already active would create two `active` rows and crash
    // `getActivePlan` (it reads with getSingleOrNull). Queue the unfrozen plan
    // instead and let the active one finish first.
    final active = await repository.getActivePlan(plan.clientId);
    if (active != null && active.id != planId) {
      final queuedCount = await repository.countQueuedPlans(plan.clientId);
      await repository.updatePlanStatus(planId, 'queued', queueOrder: queuedCount + 1);
      return;
    }
    await repository.updatePlanStatus(planId, 'active');
  }

  Future<void> deletePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    // Remove the auto-income recorded for this plan before deleting it
    // (deleting first would let the FK null out the `planId` link). A plan
    // delete reverses its income so the ledger and the per-plan share section
    // stay in sync.
    await db.deleteTransactionsForPlan(planId);
    // Attendance history belongs to the plan: deleting a plan removes the
    // records that consumed its sessions. History is only kept for plans that
    // still exist (active / expired / frozen / queued).
    await db.deleteAttendanceForPlan(planId);
    await repository.deletePlan(planId);
    // Deleting the running plan must promote the next queued plan, otherwise
    // the client ends up with queued plans stranded behind nothing.
    if (plan != null && plan.status == 'active') {
      await _promoteQueuedPlan(plan.clientId);
    }
  }

  /// Plans created from [templateId], used to propagate template edits.
  Future<List<domain.ClientPlan>> getPlansUsingTemplate(int templateId) =>
      repository.getPlansUsingTemplate(templateId);

  Future<void> consumeSession(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null || plan.status != 'active') return;
    final newRemaining = plan.remaining - 1;
    if (newRemaining <= 0) {
      // Settle at 0 so a later refund (record delete/undo) restores exactly
      // one session; the expired badge does not rely on the old marker value.
      await repository.updatePlanRemaining(planId, 0);
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

  /// Brings a previously expired plan back to active with one refunded session
  /// (used when the attendance record that consumed its last session is removed
  /// and no successor plan is active). Capped at the plan's total.
  Future<void> reactivatePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null || plan.status == 'queued') return;
    var restored = plan.remaining + 1;
    if (restored > plan.sessions) restored = plan.sessions;
    await db.patchPlan(
      planId,
      ClientPlansCompanion(
        status: const Value('active'),
        remaining: Value(restored),
        queueOrder: const Value(null),
      ),
    );
  }

  /// Puts an untouched active plan back into the queue.
  ///
  /// Used when a refund reactivates the plan this one succeeded: the successor
  /// never consumed a session, so it must not keep the active slot (two active
  /// plans make [getActivePlan] ambiguous), and its start date is cleared
  /// because its day count has not really begun. `queueOrder: 0` puts it ahead
  /// of plans queued behind it.
  Future<void> requeuePlan(int planId) async {
    final plan = await repository.getPlan(planId);
    if (plan == null || !plan.isActive) return;
    await db.patchPlan(
      planId,
      ClientPlansCompanion(
        status: const Value('queued'),
        startDate: const Value(null),
        queueOrder: const Value(0),
      ),
    );
  }

  /// Marks every `active` plan whose duration has elapsed as `expired` and
  /// promotes the next queued plan for each affected client.
  ///
  /// [consumeSession] was the only code that ever expired a plan, and it did so
  /// only when the *sessions* ran out — so a plan whose `days` had passed kept
  /// running: it stayed `active` on the card and profile, kept consuming
  /// sessions, and blocked the client's queued plans indefinitely.
  ///
  /// Sweeps one client with [clientId], or every client without it. Safe to
  /// call on every read: it only writes when a plan actually ran out of days.
  ///
  /// Frozen plans are deliberately skipped — a frozen plan is paused, and the
  /// app stores no freeze timestamp to measure elapsed days from.
  Future<void> expireElapsedPlans({int? clientId}) async {
    final rows = clientId == null
        ? await db.select(db.clientPlans).get()
        : await (db.select(db.clientPlans)..where((p) => p.clientId.equals(clientId))).get();
    final affectedClients = <int>{};
    for (final row in rows) {
      if (row.status != 'active' || row.days <= 0) continue;
      if (!planDaysElapsed(startDate: row.startDate, days: row.days)) continue;
      await db.updatePlanStatus(row.id, 'expired');
      affectedClients.add(row.clientId);
    }
    for (final affected in affectedClients) {
      await _promoteQueuedPlan(affected);
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

  /// Records (or corrects) the price and gym share of an existing plan and
  /// keeps the ledger in sync with an income row. Works for every plan status
  /// (active, frozen, queued, expired): old plans created before the pricing
  /// feature get their revenue entered retroactively via [setPlanPrice].
  /// Setting a price of 0 removes the income row recorded for the plan.
  Future<void> setPlanPrice(int planId, int price, int sharePercent) async {
    final plan = await repository.getPlan(planId);
    if (plan == null) return;
    if (price < 0) price = 0;
    var share = sharePercent;
    if (share < 0) share = 0;
    if (share > 100) share = 100;
    await db.patchPlan(
      planId,
      ClientPlansCompanion(price: Value(price), sharePercent: Value(share)),
    );
    // Income belongs to the period the plan ran: use its start date, falling
    // back to today for queued plans without one.
    final incomeDate = (plan.startDate != null && plan.startDate!.isNotEmpty)
        ? plan.startDate!
        : jalaliToday();
    final linked = await db.getTransactionsForPlan(planId);
    final income =
        linked.where((t) => t.type == 'income' && t.category == 'plan').firstOrNull;
    if (price > 0) {
      if (income == null) {
        await db.insertTransaction(TransactionsCompanion(
          clientId: Value(plan.clientId),
          planId: Value(planId),
          type: const Value('income'),
          category: const Value('plan'),
          amount: Value(price),
          date: Value(incomeDate),
          note: const Value(''),
        ));
      } else if (income.amount != price || income.date != incomeDate) {
        await db.updateTransaction(TransactionsCompanion(
          id: Value(income.id),
          clientId: Value(plan.clientId),
          planId: Value(planId),
          type: const Value('income'),
          category: const Value('plan'),
          amount: Value(price),
          date: Value(incomeDate),
          note: Value(income.note),
          createdAt: Value(income.createdAt),
        ));
      }
    } else if (income != null) {
      await db.deleteTransaction(income.id);
    }
  }

  /// The gym's share of a plan's price, rounded down: `price * sharePercent / 100`.
  int planShareDeduction(domain.ClientPlan plan) => (plan.price * plan.sharePercent) ~/ 100;

  /// Remaining days for an active/frozen plan, or `null` for queued/expired
  /// plans and for plans without a start date.
  ///
  /// The date maths lives in [planRemainingDays] so widgets (the client card,
  /// the plan card) can show the same number without going through a service.
  int? getRemainingDays(domain.ClientPlan plan) {
    if (plan.status != 'active' && plan.status != 'frozen') return null;
    return planRemainingDays(startDate: plan.startDate, days: plan.days);
  }
}
