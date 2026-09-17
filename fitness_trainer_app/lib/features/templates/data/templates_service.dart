import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/templates/domain/plan_template.dart' as domain;
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';

class TemplatesService {
  final TemplatesRepository repository;
  final PlansService? plansService;
  TemplatesService(this.repository, {this.plansService});

  Future<List<domain.PlanTemplate>> getAllTemplates() => repository.getAllTemplates();
  Future<domain.PlanTemplate?> getTemplate(int id) => repository.getTemplate(id);

  Future<int> createTemplate(String name, int sessions, int days) async {
    if (name.trim().isEmpty) throw ArgumentError('نام قالب نمی‌تواند خالی باشد');
    if (sessions <= 0 || days <= 0) throw ArgumentError('جلسات و روزها باید بزرگتر از صفر باشند');
    return repository.insertTemplate(PlanTemplatesCompanion.insert(
      name: name.trim(),
      sessions: sessions,
      days: days,
    ));
  }

  Future<void> updateTemplate(int id, String name, int sessions, int days) async {
    if (name.trim().isEmpty) throw ArgumentError('نام قالب نمی‌تواند خالی باشد');
    if (sessions <= 0 || days <= 0) throw ArgumentError('جلسات و روزها باید بزرگتر از صفر باشند');
    await repository.updateTemplate(PlanTemplatesCompanion.insert(
      id: Value(id),
      name: name.trim(),
      sessions: sessions,
      days: days,
    ));
    await _propagateToPlans(id, sessions, days);
  }

  /// Business rule: editing a template updates the active/frozen plans that
  /// were created from it. Previously nothing called this path, so plan
  /// records kept the old session/day counts.
  Future<void> _propagateToPlans(int templateId, int sessions, int days) async {
    final plans = plansService;
    if (plans == null) return;
    final affected = await plans.getPlansUsingTemplate(templateId);
    for (final plan in affected) {
      if (plan.id == null) continue;
      if (plan.status == 'active' || plan.status == 'frozen') {
        await plans.updatePlanFromTemplate(plan.id!, sessions, days);
      }
    }
  }

  Future<void> deleteTemplate(int id) async => repository.deleteTemplate(id);
  Future<int> countPlansUsingTemplate(int templateId) => repository.countPlansUsingTemplate(templateId);
  Future<void> updateTemplateSessionsDays(int templateId, int sessions, int days) =>
      repository.updateTemplateSessionsDays(templateId, sessions, days);
}
