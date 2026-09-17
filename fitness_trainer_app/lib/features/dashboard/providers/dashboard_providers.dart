import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/data/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(databaseProvider));
});

final totalClientsProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getTotalClients();
});

final activePlansCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getActivePlansCount();
});

final expiredPlansCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getExpiredPlansCount();
});

final frozenPlansCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getFrozenPlansCount();
});

final queuedPlansProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getQueuedPlansCount();
});

final lowSessionPlansProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(dashboardServiceProvider).getLowSessionPlans();
});

final bonusSessionClientsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(dashboardServiceProvider).getBonusSessionClients();
});

final todayAttendanceProvider = FutureProvider.autoDispose<Map<int, String>>((ref) {
  return ref.watch(dashboardServiceProvider).getTodayAttendance();
});

/// `jalali date -> status` for every recorded day, used by the dashboard
/// calendar so a dot lands on the correct day only.
final attendanceByDateProvider = FutureProvider.autoDispose<Map<String, String>>((ref) {
  return ref.watch(dashboardServiceProvider).getAttendanceByDate();
});

/// Client names keyed by id, so lists can show names instead of raw ids.
final clientNamesProvider = FutureProvider.autoDispose<Map<int, String>>((ref) {
  return ref.watch(dashboardServiceProvider).getClientNames();
});
