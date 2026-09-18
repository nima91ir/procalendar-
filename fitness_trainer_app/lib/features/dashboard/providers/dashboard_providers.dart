import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/data/dashboard_service.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';

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

/// Today's attendance keyed by client id → {status: count}. A client can
/// have several records today, so the inner map counts statuses.
final todayAttendanceProvider = FutureProvider.autoDispose<Map<int, Map<String, int>>>((ref) {
  return ref.watch(dashboardServiceProvider).getTodayAttendance();
});

/// Client names keyed by id, so lists can show names instead of raw ids.
final clientNamesProvider = FutureProvider.autoDispose<Map<int, String>>((ref) {
  return ref.watch(dashboardServiceProvider).getClientNames();
});

/// Client id → assigned tag ids, used by tag filters (e.g. the dashboard's
/// today-attendance section).
final clientTagFilterProvider = FutureProvider.autoDispose<Map<int, List<int>>>((ref) async {
  final clients = await ref.watch(clientsServiceProvider).getAllClients();
  final tagsService = ref.watch(tagsServiceProvider);
  final result = <int, List<int>>{};
  for (final client in clients) {
    result[client.id!] = await tagsService.getClientTagIds(client.id!);
  }
  return result;
});

/// Client ids that own at least one plan in [status]
/// ('expired' | 'frozen' | 'queued'), for the dashboard drill-downs.
final planStatusClientIdsProvider = FutureProvider.autoDispose.family<List<int>, String>((ref, status) {
  return ref.watch(dashboardServiceProvider).getClientIdsByPlanStatus(status);
});

/// Resolves the active [ClientQuickFilter] to the set of client ids the
/// clients list should show, or `null` when no filtering applies (`all`).
final quickFilterClientIdsProvider = FutureProvider.autoDispose<Set<int>?>((ref) async {
  final filter = ref.watch(clientQuickFilterProvider);
  switch (filter) {
    case ClientQuickFilter.all:
      return null;
    case ClientQuickFilter.expired:
      return (await ref.watch(planStatusClientIdsProvider('expired').future)).toSet();
    case ClientQuickFilter.frozen:
      return (await ref.watch(planStatusClientIdsProvider('frozen').future)).toSet();
    case ClientQuickFilter.queued:
      return (await ref.watch(planStatusClientIdsProvider('queued').future)).toSet();
    case ClientQuickFilter.lowSession:
      final rows = await ref.watch(lowSessionPlansProvider.future);
      return {for (final row in rows) row['clientId'] as int};
    case ClientQuickFilter.bonus:
      final rows = await ref.watch(bonusSessionClientsProvider.future);
      return {for (final row in rows) row['clientId'] as int};
  }
});
