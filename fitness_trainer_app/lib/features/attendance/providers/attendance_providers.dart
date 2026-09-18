import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
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

/// Map of `jalali date -> list of recorded statuses` for a single client,
/// ready for [AttendanceCalendar]. A client can have more than one record on
/// the same day, so the value is a list.
final clientAttendanceMapProvider = FutureProvider.autoDispose.family<Map<String, List<String>>, int>((ref, clientId) async {
  final records = await ref.watch(clientAttendanceProvider(clientId).future);
  final map = <String, List<String>>{};
  for (final record in records) {
    map.putIfAbsent(record.date, () => []).add(record.status);
  }
  return map;
});

final todayAttendanceCountProvider = FutureProvider.autoDispose.family<int, int>((ref, clientId) async {
  final today = jalaliToday();
  final records = await ref.watch(clientAttendanceProvider(clientId).future);
  return records.where((r) => r.date == today).length;
});
final todayAttendanceStatusCountsProvider = FutureProvider.autoDispose.family<Map<String, int>, int>((ref, clientId) async {
  final today = jalaliToday();
  final records = await ref.watch(clientAttendanceProvider(clientId).future);
  final todayRecords = records.where((r) => r.date == today);
  final counts = <String, int>{};
  for (final record in todayRecords) {
    counts[record.status] = (counts[record.status] ?? 0) + 1;
  }
  return counts;
});

final planAttendanceProvider = FutureProvider.autoDispose.family<List<AttendanceRecord>, int>((ref, planId) {
  return ref.watch(attendanceServiceProvider).getPlanAttendance(planId);
});

final planAttendanceMapProvider = FutureProvider.autoDispose.family<Map<String, List<String>>, int>((ref, planId) async {
  final records = await ref.watch(planAttendanceProvider(planId).future);
  final map = <String, List<String>>{};
  for (final record in records) {
    map.putIfAbsent(record.date, () => []).add(record.status);
  }
  return map;
});

class AttendanceNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addSession(int clientId, String date, {String status = 'present', int? planId}) async {
    final service = ref.read(attendanceSessionServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.addSession(clientId, date, status: status, planId: planId);
      _invalidateFor(clientId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeSession(int clientId, String date) async {
    final service = ref.read(attendanceSessionServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.removeSession(clientId, date);
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
    ref.invalidate(clientAttendanceMapProvider(clientId));
    ref.invalidate(todayAttendanceCountProvider(clientId));
    ref.invalidate(todayAttendanceStatusCountsProvider(clientId));
    ref.invalidate(clientPlansProvider(clientId));
    ref.invalidate(activePlanProvider(clientId));
    ref.invalidate(planAttendanceProvider);
    ref.invalidate(planAttendanceMapProvider);
    ref.invalidateAppData();
  }
}
