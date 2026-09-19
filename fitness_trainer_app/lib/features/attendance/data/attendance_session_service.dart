import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';

/// Orchestrates the attendance <-> plan-session business rules:
///
/// 1. Adding an attendance record (present *or* absent) consumes one session
///    from the active plan.
/// 2. When the active plan has no sessions left, a bonus session is consumed
///    instead of the plan session.
/// 3. Consuming the last session expires the plan and promotes the first
///    queued plan (handled by [PlansService.consumeSession]).
/// 4. Every record stores the `planId` it was *actually* consumed from
///    (`null` = a bonus session), so removing a record refunds the session to
///    the exact source instead of guessing from the current state.
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

  /// Adds a record and consumes its session. The record stores the plan the
  /// session was actually taken from (or `null` for a bonus session), so the
  /// refund later returns it to the right place.
  Future<int> addSession(int clientId, String date, {String status = 'present'}) async {
    final active = await plansService.getActivePlan(clientId);
    final int? planId = (active != null && active.id != null && active.remaining > 0) ? active.id : null;
    final recordId = await attendanceService.addAttendance(clientId, date, status, planId: planId);
    if (planId != null) {
      await plansService.consumeSession(planId);
    } else {
      await _consumeBonusSession(clientId);
    }
    return recordId;
  }

  /// Removes a single record by id and refunds the session it consumed.
  /// Returns the client id the record belonged to (for provider invalidation),
  /// or null when no record matched the id.
  Future<int?> removeSessionById(int attendanceId) async {
    final record = await attendanceService.getAttendanceById(attendanceId);
    if (record == null) return null;
    await attendanceService.deleteAttendanceById(attendanceId);
    await _refund(record);
    return record.clientId;
  }

  /// Removes the *latest* record for a client/day (the dashboard undo) and
  /// refunds the consumed session.
  Future<int?> removeLatestSession(int clientId, String date) async {
    final record = await attendanceService.getLatestAttendance(clientId, date);
    if (record?.id == null) return null;
    return removeSessionById(record!.id!);
  }

  /// Refunds the session back to where the record said it came from.
  ///
  /// - A record consumed from an active/frozen plan -> back to that plan.
  /// - A record consumed from the last session of an expired plan -> the plan
  ///   is reactivated only when nothing else is active; otherwise the refund
  ///   goes to the successor active plan, or to a bonus session when the
  ///   successor is already full.
  /// - A record with no `planId` (bonus session) -> bonus is restored.
  Future<void> _refund(AttendanceRecord record) async {
    final planId = record.planId;
    if (planId == null) {
      await _restoreBonusSession(record.clientId);
      return;
    }
    final plan = await plansService.getPlan(planId);
    if (plan == null) {
      await _restoreBonusSession(record.clientId);
      return;
    }
    if (plan.status == 'active' || plan.status == 'frozen') {
      if (plan.remaining < plan.sessions) {
        await plansService.restoreSession(planId);
      }
      return;
    }
    if (plan.status == 'expired') {
      final active = await plansService.getActivePlan(record.clientId);
      if (active == null) {
        await plansService.reactivatePlan(planId);
      } else if (active.id != null && active.remaining < active.sessions) {
        await plansService.restoreSession(active.id!);
      } else {
        await _restoreBonusSession(record.clientId);
      }
      return;
    }
    // 'queued' can never be a consumed plan; treat as a bonus fallback.
    await _restoreBonusSession(record.clientId);
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