import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/features/templates/domain/plan_template.dart' as domain;

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepository(ref.watch(databaseProvider));
});

final templatesServiceProvider = Provider<TemplatesService>((ref) {
  return TemplatesService(ref.watch(templatesRepositoryProvider));
});

final templatesProvider = NotifierProvider<TemplatesNotifier, List<domain.PlanTemplate>>(() {
  return TemplatesNotifier();
});

final allTemplatesProvider = FutureProvider.autoDispose<List<domain.PlanTemplate>>((ref) {
  return ref.watch(templatesServiceProvider).getAllTemplates();
});

class TemplatesNotifier extends Notifier<List<domain.PlanTemplate>> {
  @override
  List<domain.PlanTemplate> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final service = ref.read(templatesServiceProvider);
    state = await service.getAllTemplates();
  }

  Future<void> addTemplate(String name, int sessions, int days) async {
    final service = ref.read(templatesServiceProvider);
    final id = await service.createTemplate(name, sessions, days);
    state = [...state, domain.PlanTemplate(id: id, name: name, sessions: sessions, days: days)];
  }

  Future<void> updateTemplate(int id, String name, int sessions, int days) async {
    final service = ref.read(templatesServiceProvider);
    await service.updateTemplate(id, name, sessions, days);
    await _load();
  }

  Future<void> deleteTemplate(int id) async {
    final service = ref.read(templatesServiceProvider);
    await service.deleteTemplate(id);
    state = state.where((t) => t.id != id).toList();
  }
}
