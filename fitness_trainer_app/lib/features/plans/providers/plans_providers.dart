import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as domain;

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.watch(databaseProvider));
});

final plansServiceProvider = Provider<PlansService>((ref) {
  return PlansService(ref.watch(plansRepositoryProvider), ref.watch(databaseProvider));
});

final plansProvider = NotifierProvider<PlansNotifier, List<domain.ClientPlan>>(() {
  return PlansNotifier();
});

final clientPlansProvider = FutureProvider.autoDispose.family<List<domain.ClientPlan>, int>((ref, clientId) {
  return ref.watch(plansServiceProvider).getClientPlans(clientId);
});

class PlansNotifier extends Notifier<List<domain.ClientPlan>> {
  @override
  List<domain.ClientPlan> build() => [];

  Future<void> loadClientPlans(int clientId) async {
    final service = ref.read(plansServiceProvider);
    state = await service.getClientPlans(clientId);
  }

  Future<void> assignPlan(int clientId, int templateId, int sessions, int days) async {
    final service = ref.read(plansServiceProvider);
    await service.assignPlan(clientId, templateId, sessions, days);
  }

  Future<void> freezePlan(int planId) async {
    final service = ref.read(plansServiceProvider);
    await service.freezePlan(planId);
    await _reloadForPlan(planId);
  }

  Future<void> unfreezePlan(int planId) async {
    final service = ref.read(plansServiceProvider);
    await service.unfreezePlan(planId);
    await _reloadForPlan(planId);
  }

  Future<void> deletePlan(int planId) async {
    final service = ref.read(plansServiceProvider);
    final plan = await service.getPlan(planId);
    await service.deletePlan(planId);
    if (plan != null) {
      await loadClientPlans(plan.clientId);
    }
  }

  Future<void> updatePlanFromTemplate(int planId, int sessions, int days) async {
    final service = ref.read(plansServiceProvider);
    await service.updatePlanFromTemplate(planId, sessions, days);
    await _reloadForPlan(planId);
  }

  Future<void> _reloadForPlan(int planId) async {
    final plan = await ref.read(plansServiceProvider).getPlan(planId);
    if (plan != null) {
      await loadClientPlans(plan.clientId);
    }
  }
}
