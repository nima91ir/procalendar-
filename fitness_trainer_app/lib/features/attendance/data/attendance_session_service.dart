import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
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
/// 4. Removing a record restores whatever was consumed, when it can be
///    determined.
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

Future<void> _consumeBonusSession(int clientId) async {
    final client = await clientsRepository.getClient(clientId);
    if (client == null || client.bonusSessions <= 0) return;
    await clientsRepository.updateClientBonus(clientId, client.bonusSessions - 1);
  }

  Future<void> addSession(int clientId, String date, {String status = 'present', int? planId}) async {
    await attendanceService.addAttendance(clientId, date, status, planId: planId);
    await consumeSession(clientId);
  }

  Future<void> removeSession(int clientId, String date) async {
    final removed = await attendanceService.removeOneAttendance(clientId, date);
    if (removed > 0) {
      await restoreSession(clientId);
    }
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
