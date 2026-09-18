import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';

/// Covers the dashboard stat-card drill-downs: each quick filter must resolve
/// to the correct set of client ids (or `null` for "all").
void main() {
  test('quick filter resolves the matching client ids', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final templates = TemplatesService(TemplatesRepository(db));
    final plans = PlansService(PlansRepository(db), db);
    final clients = ClientsService(ClientsRepository(db));
    final templateId = await templates.createTemplate('T', 5, 30);

    final frozenClientId = await clients.createClient('متوقف');
    final frozenPlanId = await plans.assignPlan(frozenClientId, templateId, 5, 30);
    await plans.freezePlan(frozenPlanId);

    final bonusClientId = await clients.createClient('هدیه', bonusSessions: 2);

    final lowSessionClientId = await clients.createClient('رو به اتمام');
    await plans.assignPlan(lowSessionClientId, templateId, 2, 30);

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    container.read(clientQuickFilterProvider.notifier).set(ClientQuickFilter.frozen);
    expect(await container.read(quickFilterClientIdsProvider.future), {frozenClientId});

    container.read(clientQuickFilterProvider.notifier).set(ClientQuickFilter.bonus);
    expect(await container.read(quickFilterClientIdsProvider.future), {bonusClientId});

    container.read(clientQuickFilterProvider.notifier).set(ClientQuickFilter.lowSession);
    expect(await container.read(quickFilterClientIdsProvider.future), {lowSessionClientId});

    container.read(clientQuickFilterProvider.notifier).set(ClientQuickFilter.all);
    expect(await container.read(quickFilterClientIdsProvider.future), isNull);
  });

  test('plan status lookup returns distinct owning client ids', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final templates = TemplatesService(TemplatesRepository(db));
    final plans = PlansService(PlansRepository(db), db);
    final clients = ClientsService(ClientsRepository(db));
    final templateId = await templates.createTemplate('T', 5, 30);

    final clientId = await clients.createClient('سارا');
    await plans.assignPlan(clientId, templateId, 5, 30);
    await plans.assignPlan(clientId, templateId, 5, 30);

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(await container.read(planStatusClientIdsProvider('active').future), [clientId]);
    expect(await container.read(planStatusClientIdsProvider('expired').future), isEmpty);
  });
}
