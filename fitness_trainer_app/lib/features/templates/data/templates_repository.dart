import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/templates/domain/plan_template.dart' as domain;

class TemplatesRepository {
  final AppDatabase db;
  TemplatesRepository(this.db);

  Future<List<domain.PlanTemplate>> getAllTemplates() async {
    final rows = await db.getAllTemplates();
    return rows.map((r) => domain.PlanTemplate(
      id: r.id,
      name: r.name,
      sessions: r.sessions,
      days: r.days,
    )).toList();
  }

  Future<domain.PlanTemplate?> getTemplate(int id) async {
    final row = await db.getTemplate(id);
    if (row == null) return null;
    return domain.PlanTemplate(
      id: row.id,
      name: row.name,
      sessions: row.sessions,
      days: row.days,
    );
  }

  Future<int> insertTemplate(PlanTemplatesCompanion insert) => db.insertTemplate(insert);
  Future<bool> updateTemplate(PlanTemplatesCompanion insert) => db.updateTemplate(insert);
  Future<int> deleteTemplate(int id) => db.deleteTemplate(id);
  Future<int> countPlansUsingTemplate(int templateId) => db.countPlansUsingTemplate(templateId);
  Future<void> updateTemplateSessionsDays(int templateId, int sessions, int days) async {
    final template = await getTemplate(templateId);
    if (template == null) return;
    await db.updateTemplate(PlanTemplatesCompanion.insert(
      id: Value(templateId),
      name: template.name,
      sessions: sessions,
      days: days,
    ));
  }
}
