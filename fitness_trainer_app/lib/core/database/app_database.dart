import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/connection/shared.dart' as connection;
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';

part 'app_database.g.dart';

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get bonusSessions => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant(''))();
  IntColumn get color => integer().withDefault(const Constant(0xFF88A36B))();
}

class ClientTags extends Table {
  IntColumn get clientId => integer().references(Clients, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {clientId, tagId};
}

class PlanTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get sessions => integer()();
  IntColumn get days => integer()();
}

class ClientPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id, onDelete: KeyAction.cascade)();
  IntColumn get templateId => integer().references(PlanTemplates, #id)();
  TextColumn get startDate => text().nullable()();
  IntColumn get sessions => integer()();
  IntColumn get days => integer()();
  IntColumn get remaining => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get queueOrder => integer().nullable()();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
}

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text()();
  TextColumn get status => text()();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Clients,
  Tags,
  ClientTags,
  PlanTemplates,
  ClientPlans,
  Attendance,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static Future<AppDatabase> create() async {
    final executor = await connection.createExecutor();
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(clientPlans, clientPlans.queueOrder);
        }
      },
    );
  }

  Future<List<Client>> getAllClients() => select(clients).get();
  Future<Client?> getClient(int id) => (select(clients)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<int> insertClient(ClientsCompanion insert) => into(clients).insert(insert);
  Future<bool> updateClient(ClientsCompanion insert) => update(clients).replace(insert);
  Future<int> deleteClient(int id) => (delete(clients)..where((c) => c.id.equals(id))).go();
  Future<List<Client>> searchClients(String query) {
    final lower = '%${query.toLowerCase()}%';
    return (select(clients)..where((c) => c.name.like(lower))).get();
  }
  Stream<List<Client>> watchAllClients() => select(clients).watch();

  Future<List<Tag>> getAllTags() => (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  Future<Tag?> getTag(int id) => (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTag(TagsCompanion insert) => into(tags).insert(insert);
  Future<bool> updateTag(TagsCompanion insert) => update(tags).replace(insert);
  Future<int> deleteTag(int id) => (delete(tags)..where((t) => t.id.equals(id))).go();
  Future<void> assignTagToClient(int clientId, int tagId) async {
    await into(clientTags).insert(ClientTagsCompanion.insert(clientId: clientId, tagId: tagId), mode: InsertMode.insertOrIgnore);
  }
  Future<void> removeTagFromClient(int clientId, int tagId) async {
    await (delete(clientTags)..where((ct) => ct.clientId.equals(clientId) & ct.tagId.equals(tagId))).go();
  }
  Future<List<int>> getClientTagIds(int clientId) async {
    final rows = await (select(clientTags)..where((ct) => ct.clientId.equals(clientId))).get();
    return rows.map((r) => r.tagId).toList();
  }
  Future<int> countClientsWithTag(int tagId) async {
    final rows = await (select(clientTags)..where((ct) => ct.tagId.equals(tagId))).get();
    return rows.length;
  }

  Future<List<PlanTemplate>> getAllTemplates() => (select(planTemplates)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  Future<PlanTemplate?> getTemplate(int id) => (select(planTemplates)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTemplate(PlanTemplatesCompanion insert) => into(planTemplates).insert(insert);
  Future<bool> updateTemplate(PlanTemplatesCompanion insert) => update(planTemplates).replace(insert);
  Future<int> deleteTemplate(int id) => (delete(planTemplates)..where((t) => t.id.equals(id))).go();
  Future<int> countPlansUsingTemplate(int templateId) async {
    final rows = await (select(clientPlans)..where((p) => p.templateId.equals(templateId))).get();
    return rows.length;
  }

  Future<List<ClientPlan>> getClientPlans(int clientId) => (select(clientPlans)..where((p) => p.clientId.equals(clientId))).get();
  Future<ClientPlan?> getActivePlan(int clientId) => (select(clientPlans)..where((p) => p.clientId.equals(clientId) & p.status.equals('active'))).getSingleOrNull();
  Future<ClientPlan?> getFrozenPlan(int clientId) async {
    final plans = await getClientPlans(clientId);
    return plans.where((p) => p.status == 'frozen').firstOrNull;
  }
  Future<ClientPlan?> getPlan(int id) => (select(clientPlans)..where((p) => p.id.equals(id))).getSingleOrNull();
  Future<int> insertPlan(ClientPlansCompanion insert) => into(clientPlans).insert(insert);
  Future<bool> updatePlan(ClientPlansCompanion insert) => update(clientPlans).replace(insert);
  Future<int> deletePlan(int id) => (delete(clientPlans)..where((p) => p.id.equals(id))).go();
  Future<List<ClientPlan>> getQueuedPlans() => (select(clientPlans)..where((p) => p.status.equals('queued'))).get();
  Future<List<ClientPlan>> getAllPlans() => select(clientPlans).get();
  Future<int> countQueuedPlans(int clientId) async {
    final rows = await (select(clientPlans)..where((p) => p.clientId.equals(clientId) & p.status.equals('queued'))).get();
    return rows.length;
  }
  Future<void> updatePlanRemaining(int planId, int remaining) async {
    final plan = await getPlan(planId);
    if (plan == null) return;
    await updatePlan(ClientPlansCompanion.insert(
      id: Value(planId),
      clientId: plan.clientId,
      templateId: plan.templateId,
      sessions: plan.sessions,
      days: plan.days,
      remaining: remaining,
      status: Value(plan.status),
      queueOrder: plan.queueOrder != null ? Value(plan.queueOrder!) : const Value.absent(),
    ));
  }
  Future<void> updatePlanStatus(int planId, String status, {int? queueOrder}) async {
    final plan = await getPlan(planId);
    if (plan == null) return;
    await updatePlan(ClientPlansCompanion.insert(
      id: Value(planId),
      clientId: plan.clientId,
      templateId: plan.templateId,
      sessions: plan.sessions,
      days: plan.days,
      remaining: plan.remaining,
      status: Value(status),
      queueOrder: queueOrder != null ? Value(queueOrder) : Value(null),
    ));
  }

  Future<void> clearPlanQueueOrder(int planId) async {
    await customUpdate('UPDATE client_plans SET queue_order = NULL WHERE id = ?', variables: [Variable<int>(planId)]);
  }

  Future<List<AttendanceData>> getClientAttendance(int clientId) => (select(attendance)..where((a) => a.clientId.equals(clientId))..orderBy([(a) => OrderingTerm.desc(a.date)])).get();
  Future<AttendanceData?> getAttendance(int clientId, String date) => (select(attendance)..where((a) => a.clientId.equals(clientId) & a.date.equals(date))).getSingleOrNull();
  Future<int> insertAttendance(AttendanceCompanion insert) => into(attendance).insert(insert);
  Future<bool> updateAttendance(AttendanceCompanion insert) => update(attendance).replace(insert);
  Future<int> deleteAttendance(int id) => (delete(attendance)..where((a) => a.id.equals(id))).go();
  Stream<List<AttendanceData>> watchClientAttendance(int clientId) => (select(attendance)..where((a) => a.clientId.equals(clientId))..orderBy([(a) => OrderingTerm.desc(a.date)])).watch();

  Future<int> getTotalClients() async => (await select(clients).get()).length;
  Future<int> getActivePlansCount() async => (await (select(clientPlans)..where((p) => p.status.equals('active'))).get()).length;
  Future<int> getExpiredPlansCount() async => (await (select(clientPlans)..where((p) => p.status.equals('expired'))).get()).length;
  Future<int> getFrozenPlansCount() async => (await (select(clientPlans)..where((p) => p.status.equals('frozen'))).get()).length;
  Future<int> getQueuedPlansCount() async => (await (select(clientPlans)..where((p) => p.status.equals('queued'))).get()).length;
  Future<List<Map<String, dynamic>>> getLowSessionPlans() async {
    final rows = await (select(clientPlans)..where((p) => p.status.equals('active'))).get();
    return rows.where((p) => p.remaining < 3).map((p) => {'planId': p.id, 'clientId': p.clientId, 'remaining': p.remaining}).toList();
  }
  Future<List<Map<String, dynamic>>> getBonusSessionClients() async {
    final rows = await select(clients).get();
    return rows.where((c) => c.bonusSessions > 0).map((c) => {'clientId': c.id, 'clientName': c.name, 'bonusSessions': c.bonusSessions}).toList();
  }
  Future<Map<int, String>> getTodayAttendance() async {
    final date = jalaliToday();
    final rows = await (select(attendance)..where((a) => a.date.equals(date))).get();
    return {for (var r in rows) r.clientId: r.status};
  }
}
