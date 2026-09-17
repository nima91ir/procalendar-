import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_session_service.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(databaseProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.watch(attendanceRepositoryProvider), ref.watch(databaseProvider));
});

/// Attendance + session consumption (plan session, then bonus session).
final attendanceSessionServiceProvider = Provider<AttendanceSessionService>((ref) {
  return AttendanceSessionService(
    ref.watch(attendanceServiceProvider),
    ref.watch(plansServiceProvider),
    ref.watch(clientsRepositoryProvider),
  );
});

final attendanceProvider = NotifierProvider<AttendanceNotifier, AsyncValue<void>>(() {
  return AttendanceNotifier();
});

final clientAttendanceProvider = FutureProvider.autoDispose.family<List<AttendanceRecord>, int>((ref, clientId) {
  return ref.watch(attendanceServiceProvider).getClientAttendance(clientId);
});

/// Map of `jalali date -> status` for a single client, ready for
/// [AttendanceCalendar].
final clientAttendanceMapProvider = FutureProvider.autoDispose.family<Map<String, String>, int>((ref, clientId) async {
  final records = await ref.watch(clientAttendanceProvider(clientId).future);
  return {for (final record in records) record.date: record.status};
});

class AttendanceNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> markAttendance(int clientId, String date, String status) async {
    final service = ref.read(attendanceSessionServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.markAttendance(clientId, date, status);
      _invalidateFor(clientId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> undoAttendance(int clientId, String date) async {
    final service = ref.read(attendanceSessionServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.undoAttendance(clientId, date);
      _invalidateFor(clientId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Attendance changes consume sessions, so the client's plans, lists and
  /// the dashboard aggregates have to be refreshed too.
  void _invalidateFor(int clientId) {
    ref.invalidate(clientAttendanceProvider(clientId));
    ref.invalidate(clientPlansProvider(clientId));
    ref.invalidateAppData();
  }
}

