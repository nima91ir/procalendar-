import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';

/// Orchestrates the attendance <-> plan-session business rules that were
/// previously implemented but never reachable from the UI:
///
/// 1. Marking attendance (present *or* absent) consumes one session from the
///    active plan.
/// 2. When the active plan has no sessions left, a bonus session is consumed
///    instead of the plan session.
/// 3. Consuming the last session expires the plan and promotes the first
///    queued plan (handled by [PlansService.consumeSession]).
/// 4. Undo restores whatever was consumed, when it can be determined.
///
/// Consumption is idempotent: one attendance record per client/day can only
/// ever consume a single session, so re-marking the same day (for example
/// switching present -> absent) does not drain the plan.
class AttendanceSessionService {
  final AttendanceService attendanceService;
  final PlansService plansService;
  final ClientsRepository clientsRepository;

  AttendanceSessionService(this.attendanceService, this.plansService, this.clientsRepository);

  /// Records attendance for [date] and consumes a session only when this is
  /// the first record for that day.
  Future<AttendanceRecord?> markAttendance(int clientId, String date, String status) async {
    final existing = await attendanceService.getAttendance(clientId, date);
    final record = await attendanceService.markAttendance(clientId, date, status);
    if (record == null) return null;
    if (existing == null) {
      await consumeSession(clientId);
    }
    return record;
  }

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

  Future<void> _consumeBonusSession(int clientId) async {
    final client = await clientsRepository.getClient(clientId);
    if (client == null || client.bonusSessions <= 0) return;
    await clientsRepository.updateClientBonus(clientId, client.bonusSessions - 1);
  }

  /// Deletes the attendance record for [date] and gives the consumed session
  /// back. Returns false when there was nothing to undo.
  Future<bool> undoAttendance(int clientId, String date) async {
    final existing = await attendanceService.getAttendance(clientId, date);
    if (existing == null) return false;
    await attendanceService.undoAttendance(clientId, date);
    await restoreSession(clientId);
    return true;
  }

  /// Gives back one session if it can be determined where it came from.
  ///
  /// If the active plan is short of its total, the session is returned to it.
  /// If the client has no active plan at all, a bonus session is added back.
  /// A plan that already expired and was replaced by a queued plan cannot be
  /// rewound, so nothing is restored in that case.
  Future<void> restoreSession(int clientId) async {
    final active = await plansService.getActivePlan(clientId);
    if (active != null && active.id != null && active.remaining < active.sessions) {
      await plansService.restoreSession(active.id!);
      return;
    }
    if (active == null) {
      final client = await clientsRepository.getClient(clientId);
      if (client == null) return;
      await clientsRepository.updateClientBonus(clientId, client.bonusSessions + 1);
    }
  }
}
