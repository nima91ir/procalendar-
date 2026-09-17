import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_service.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(databaseProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.watch(attendanceRepositoryProvider), ref.watch(databaseProvider));
});

final attendanceProvider = NotifierProvider<AttendanceNotifier, AsyncValue<void>>(() {
  return AttendanceNotifier();
});

final clientAttendanceProvider = FutureProvider.autoDispose.family<List<AttendanceRecord>, int>((ref, clientId) {
  return ref.watch(attendanceServiceProvider).getClientAttendance(clientId);
});

class AttendanceNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> markAttendance(int clientId, String date, String status) async {
    final service = ProviderContainer().read(attendanceServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.markAttendance(clientId, date, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> undoAttendance(int clientId, String date) async {
    final service = ProviderContainer().read(attendanceServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.undoAttendance(clientId, date);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
