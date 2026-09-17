import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/templates/domain/plan_template.dart' as domain;
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';

class TemplatesService {
  final TemplatesRepository repository;
  TemplatesService(this.repository);

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
  }

  Future<void> deleteTemplate(int id) async => repository.deleteTemplate(id);
  Future<int> countPlansUsingTemplate(int templateId) => repository.countPlansUsingTemplate(templateId);
  Future<void> updateTemplateSessionsDays(int templateId, int sessions, int days) =>
      repository.updateTemplateSessionsDays(templateId, sessions, days);
}
