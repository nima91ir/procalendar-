import 'package:fitness_trainer_app/core/utils/plan_dates.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/attendance/domain/session_refund.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';

export 'package:fitness_trainer_app/features/attendance/domain/session_refund.dart';

/// `planId` stored on an attendance record when the add consumed **nothing**
/// (no plan sessions left *and* no bonus session available). Removing such a
/// record must not hand out a session that was never consumed.
///
/// Plan ids auto-increment from 1, so 0 can never collide with a real plan;
/// `null` keeps its meaning of "consumed a bonus session".
const int kNoSessionConsumed = 0;

/// Orchestrates the attendance <-> plan-session business rules:
///
/// 1. Adding an attendance record (present *or* absent) consumes one session
///    from the active plan.
/// 2. When the active plan has no sessions left, a bonus session is consumed
///    instead of the plan session.
/// 3. When neither is available the add consumes nothing, which the record
///    remembers as [kNoSessionConsumed].
/// 4. Consuming the last session expires the plan and promotes the first
///    queued plan (handled by [PlansService.consumeSession]).
/// 5. Every record stores the `planId` it was *actually* consumed from
///    (`null` = a bonus session, [kNoSessionConsumed] = nothing), so removing
///    a record refunds the session to the exact source instead of guessing
///    from the current state.
///
/// A client may have more than one attendance record per day; every add
/// consumes a session, every removal refunds one.
class AttendanceSessionService {
  final AttendanceService attendanceService;
  final PlansService plansService;
  final ClientsRepository clientsRepository;

  AttendanceSessionService(this.attendanceService, this.plansService, this.clientsRepository);

  /// Consumes one session: from the active plan when it still has sessions,
  /// otherwise from the client's bonus sessions.
  Future<void> consumeSession(int clientId) async {
    final active = await plansService.getActivePlan(clientId);
    if (active != null && active.id != null && active.remaining > 0) {
      await plansService.consumeSession(active.id!);
      return;
    }
    await _consumeBonusSession(clientId);
  }

  /// Adds a record and consumes its session. The record stores where the
  /// session actually came from — a plan id, `null` for a bonus session, or
  /// [kNoSessionConsumed] when there was nothing left to consume — so the
  /// refund later returns it to the right place.
  Future<int> addSession(int clientId, String date, {String status = 'present'}) async {
    final active = await plansService.getActivePlan(clientId);
    final int? planId = (active != null && active.id != null && active.remaining > 0) ? active.id : null;
    // Resolved before inserting so the record can state whether a bonus
    // session was really available to consume.
    final fromBonus = planId == null && await _hasBonusSession(clientId);
    final recordId = await attendanceService.addAttendance(
      clientId,
      date,
      status,
      planId: planId ?? (fromBonus ? null : kNoSessionConsumed),
    );
    if (planId != null) {
      await plansService.consumeSession(planId);
    } else if (fromBonus) {
      await _consumeBonusSession(clientId);
    }
    return recordId;
  }

  /// Removes a single record by id and refunds the session it consumed.
  /// Returns the client id (for provider invalidation) plus where the refund
  /// landed, or null when no record matched the id.
  Future<SessionRemoval?> removeSessionById(int attendanceId) async {
    final record = await attendanceService.getAttendanceById(attendanceId);
    if (record == null) return null;
    await attendanceService.deleteAttendanceById(attendanceId);
    final refund = await _refund(record);
    return (clientId: record.clientId, refund: refund);
  }

  /// Removes the *latest* record for a client/day (the dashboard undo) and
  /// refunds the consumed session.
  Future<SessionRemoval?> removeLatestSession(int clientId, String date) async {
    final record = await attendanceService.getLatestAttendance(clientId, date);
    if (record?.id == null) return null;
    return removeSessionById(record!.id!);
  }

  /// Refunds the session back to where the record said it came from, and
  /// reports where it landed so the UI can say so.
  ///
  /// - [kNoSessionConsumed] -> nothing to refund: the add had neither a plan
  ///   session nor a bonus session to take.
  /// - A record with no `planId` (bonus session) -> the bonus is restored.
  /// - A record consumed from an active/frozen plan -> back to that plan.
  /// - A record consumed from the last session of an expired plan -> back to
  ///   that plan, which goes `active` again when its days are not over (an
  ///   untouched successor is returned to the queue, so there is still exactly
  ///   one active plan); otherwise into the active successor when it has room,
  ///   and only failing that as a bonus session.
  Future<SessionRefund> _refund(AttendanceRecord record) async {
    final planId = record.planId;
    if (planId == kNoSessionConsumed) return SessionRefund.none;
    if (planId == null) {
      await _restoreBonusSession(record.clientId);
      return SessionRefund.bonus;
    }
    final plan = await plansService.getPlan(planId);
    if (plan == null) {
      await _restoreBonusSession(record.clientId);
      return SessionRefund.bonus;
    }
    if (plan.status == 'active' || plan.status == 'frozen') {
      if (plan.remaining < plan.sessions) {
        await plansService.restoreSession(planId);
        return SessionRefund.plan;
      }
      return SessionRefund.none;
    }
    if (plan.status == 'expired') {
      final active = await plansService.getActivePlan(record.clientId);
      if (active == null) {
        await plansService.reactivatePlan(planId);
        return SessionRefund.plan;
      }
      if (active.id != null && active.remaining < active.sessions) {
        await plansService.restoreSession(active.id!);
        return SessionRefund.plan;
      }
      // The successor is untouched (full) — and it reached this branch, so the
      // recorded plan still has days left: it only ran out of *sessions*. Give
      // the session and the active slot back to the recorded plan, and put the
      // untouched successor back in the queue.
      if (planRemainingDays(startDate: plan.startDate, days: plan.days) != 0) {
        await plansService.reactivatePlan(planId);
        if (active.id != null) await plansService.requeuePlan(active.id!);
        return SessionRefund.plan;
      }
      await _restoreBonusSession(record.clientId);
      return SessionRefund.bonus;
    }
    // 'queued' can never be a consumed plan; treat as a bonus fallback.
    await _restoreBonusSession(record.clientId);
    return SessionRefund.bonus;
  }

  /// Whether the client has a bonus session available to consume.
  Future<bool> _hasBonusSession(int clientId) async {
    final client = await clientsRepository.getClient(clientId);
    return client != null && client.bonusSessions > 0;
  }

  Future<void> _consumeBonusSession(int clientId) async {
    final client = await clientsRepository.getClient(clientId);
    if (client == null || client.bonusSessions <= 0) return;
    await clientsRepository.updateClientBonus(clientId, client.bonusSessions - 1);
  }

  Future<void> _restoreBonusSession(int clientId) async {
    final client = await clientsRepository.getClient(clientId);
    if (client == null) return;
    await clientsRepository.updateClientBonus(clientId, client.bonusSessions + 1);
  }
}