import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/plan_dates.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/data/dashboard_service.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(databaseProvider));
});

final totalClientsProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(dashboardServiceProvider).getTotalClients();
});

// Every plan-based counter below depends on [plansExpirySweepProvider]: a plan
// whose duration has elapsed must not still be counted as active, and expiring
// it can promote a queued plan (so `queued`/`frozen` move too).
final activePlansCountProvider = FutureProvider.autoDispose<int>((ref) async {
  await ref.watch(plansExpirySweepProvider.future);
  return ref.watch(dashboardServiceProvider).getActivePlansCount();
});

final expiredPlansCountProvider = FutureProvider.autoDispose<int>((ref) async {
  await ref.watch(plansExpirySweepProvider.future);
  return ref.watch(dashboardServiceProvider).getExpiredPlansCount();
});

final frozenPlansCountProvider = FutureProvider.autoDispose<int>((ref) async {
  await ref.watch(plansExpirySweepProvider.future);
  return ref.watch(dashboardServiceProvider).getFrozenPlansCount();
});

final queuedPlansProvider = FutureProvider.autoDispose<int>((ref) async {
  await ref.watch(plansExpirySweepProvider.future);
  return ref.watch(dashboardServiceProvider).getQueuedPlansCount();
});

final lowSessionPlansProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  await ref.watch(plansExpirySweepProvider.future);
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
  // Two queries total instead of one per client. The previous version awaited
  // `getClientTagIds` inside a loop, so a 100-client book issued 101 sequential
  // queries — and this provider re-runs on every mutation in the app.
  //
  // The output is unchanged: every client gets an entry, empty when it carries
  // no tags. Consumers already fall back with `?? const <int>[]`, so the shape
  // is not load-bearing, but keeping it identical avoids any surprise.
  final clients = await ref.watch(clientsServiceProvider).getAllClients();
  final links = await ref.watch(tagsServiceProvider).getAllClientTags();
  final result = <int, List<int>>{
    for (final client in clients) client.id!: <int>[],
  };
  for (final link in links) {
    result.putIfAbsent(link.clientId, () => <int>[]).add(link.tagId);
  }
  return result;
});

/// Client ids that own at least one plan in [status]
/// ('expired' | 'frozen' | 'queued'), for the dashboard drill-downs.
final planStatusClientIdsProvider = FutureProvider.autoDispose.family<List<int>, String>((ref, status) async {
  await ref.watch(plansExpirySweepProvider.future);
  return ref.watch(dashboardServiceProvider).getClientIdsByPlanStatus(status);
});

/// Every client's most recent attendance date, keyed by client id. A client who
/// has never attended is simply absent from the map.
///
/// One query grouped in Dart. This backs the "away 14+ days" and "never
/// attended" filters: the app stores no schedule, so how recently somebody came
/// in is the only evidence of whether they are still training.
final lastAttendanceByClientProvider = FutureProvider.autoDispose<Map<int, String>>((ref) async {
  final records = await ref.watch(attendanceServiceProvider).getAllAttendance();
  final latest = <int, String>{};
  for (final record in records) {
    final current = latest[record.clientId];
    // Jalali `yyyy/MM/dd` keys are zero-padded, so string order is date order.
    if (current == null || record.date.compareTo(current) > 0) {
      latest[record.clientId] = record.date;
    }
  }
  return latest;
});

/// Ids of clients holding a running (`active`) plan.
Future<Set<int>> _clientsWithActivePlan(Ref ref) async {
  final plans = await ref.watch(allPlansProvider.future);
  return {
    for (final plan in plans)
      if (plan.status == 'active') plan.clientId,
  };
}

/// Client ids matching [filter].
///
/// [ClientQuickFilter.all] returns an empty set rather than every id: it means
/// "stop filtering" to the caller, which is a different thing.
Future<Set<int>> _idsForFilter(Ref ref, ClientQuickFilter filter) async {
  switch (filter) {
    case ClientQuickFilter.all:
      return const {};
    case ClientQuickFilter.expired:
    case ClientQuickFilter.frozen:
    case ClientQuickFilter.queued:
      final status = switch (filter) {
        ClientQuickFilter.expired => 'expired',
        ClientQuickFilter.frozen => 'frozen',
        _ => 'queued',
      };
      return (await ref.watch(planStatusClientIdsProvider(status).future)).toSet();
    case ClientQuickFilter.lowSession:
      final rows = await ref.watch(lowSessionPlansProvider.future);
      return {for (final row in rows) row['clientId'] as int};
    case ClientQuickFilter.bonus:
      final rows = await ref.watch(bonusSessionClientsProvider.future);
      return {for (final row in rows) row['clientId'] as int};
    case ClientQuickFilter.notMarkedToday:
      final clients = await ref.watch(allClientsProvider.future);
      final today = await ref.watch(todayAttendanceProvider.future);
      return {for (final c in clients) if (!today.containsKey(c.id)) c.id!};
    case ClientQuickFilter.stale:
      final latest = await ref.watch(lastAttendanceByClientProvider.future);
      final cutoff = addJalaliDays(jalaliToday(), -14);
      return {
        for (final entry in latest.entries)
          if (entry.value.compareTo(cutoff) < 0) entry.key,
      };
    case ClientQuickFilter.neverAttended:
      final clients = await ref.watch(allClientsProvider.future);
      final latest = await ref.watch(lastAttendanceByClientProvider.future);
      return {for (final c in clients) if (!latest.containsKey(c.id)) c.id!};
    case ClientQuickFilter.noActivePlan:
      final clients = await ref.watch(allClientsProvider.future);
      final withActive = await _clientsWithActivePlan(ref);
      return {for (final c in clients) if (!withActive.contains(c.id)) c.id!};
    case ClientQuickFilter.expiringSoon:
      final plans = await ref.watch(allPlansProvider.future);
      final ids = <int>{};
      for (final plan in plans) {
        if (plan.status != 'active' && plan.status != 'frozen') continue;
        final days = planRemainingDays(startDate: plan.startDate, days: plan.days);
        if (days != null && days >= 0 && days <= 7) ids.add(plan.clientId);
      }
      return ids;
    case ClientQuickFilter.needsAttention:
      return {
        ...await _idsForFilter(ref, ClientQuickFilter.lowSession),
        ...await _idsForFilter(ref, ClientQuickFilter.expiringSoon),
        ...await _idsForFilter(ref, ClientQuickFilter.noActivePlan),
      };
  }
}

/// Resolves the active [ClientQuickFilter] to the set of client ids the clients
/// list should show, or `null` when no filtering applies (`all`).
final quickFilterClientIdsProvider = FutureProvider.autoDispose<Set<int>?>((ref) async {
  final filter = ref.watch(clientQuickFilterProvider);
  if (filter == ClientQuickFilter.all) return null;
  return _idsForFilter(ref, filter);
});

/// How many clients each filter matches, so a chip can show its count before
/// being tapped.
///
/// Shares [_idsForFilter] with [quickFilterClientIdsProvider] deliberately: the
/// number on a chip and the list it produces can never disagree.
final clientFilterCountsProvider =
    FutureProvider.autoDispose<Map<ClientQuickFilter, int>>((ref) async {
  final counts = <ClientQuickFilter, int>{};
  for (final filter in ClientQuickFilter.values) {
    if (filter == ClientQuickFilter.all) continue;
    counts[filter] = (await _idsForFilter(ref, filter)).length;
  }
  return counts;
});
