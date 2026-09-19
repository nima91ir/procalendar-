import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/features/accounting/providers/transactions_providers.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

/// Every provider backed by database reads. Mutations anywhere in the app call
/// [invalidateAppData] so all *watching* screens refetch immediately — this
/// replaces the pattern where each screen kept a private list that only
/// refreshed when manually reloaded after `await Navigator.push(...)`.
// Typed as Object because Riverpod 3 does not export a public common supertype
// for providers/families; `invalidate` accepts them all at runtime.
final List<Object> _appDataProviders = [
  clientsProvider,
  allClientsProvider,
  clientProvider,
  clientPlansProvider,
  plansProvider,
  activePlanProvider,
  allPlansProvider,
  clientAttendanceProvider,
  clientAttendanceMapProvider,
  planAttendanceProvider,
  planAttendanceMapProvider,
  totalClientsProvider,
  activePlansCountProvider,
  expiredPlansCountProvider,
  frozenPlansCountProvider,
  queuedPlansProvider,
  lowSessionPlansProvider,
  bonusSessionClientsProvider,
  todayAttendanceProvider,
  todayAttendanceCountProvider,
  todayAttendanceStatusCountsProvider,
  planStatusClientIdsProvider,
  quickFilterClientIdsProvider,
  clientNamesProvider,
  clientTagFilterProvider,
  clientTagsProvider,
  allTagsProvider,
  tagUsageCountProvider,
  allTemplatesProvider,
  templateUsageCountProvider,
  trainerNameProvider,
  transactionsProvider,
  clientTransactionsProvider,
];

extension AppDataRefresh on Ref {
  /// Invalidate every data provider. Providers nobody is watching simply die
  /// (autoDispose) and refetch on next read.
  void invalidateAppData() {
    for (final provider in _appDataProviders) {
      invalidate(provider as dynamic);
    }
  }
}

extension AppDataRefreshOnWidgetRef on WidgetRef {
  /// Widget-side twin of [AppDataRefresh.invalidateAppData].
  void invalidateAppData() {
    for (final provider in _appDataProviders) {
      invalidate(provider as dynamic);
    }
  }
}
