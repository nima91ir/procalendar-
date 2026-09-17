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
