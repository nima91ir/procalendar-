import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/connection/shared.dart' as connection;

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
  IntColumn get price => integer().withDefault(const Constant(0))();
  IntColumn get sharePercent => integer().withDefault(const Constant(0))();
  IntColumn get remaining => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get queueOrder => integer().nullable()();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
}

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id, onDelete: KeyAction.cascade)();
  IntColumn get planId => integer().nullable()();
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

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get planId => integer().references(ClientPlans, #id, onDelete: KeyAction.setNull).nullable()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  TextColumn get date => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
}

@DriftDatabase(tables: [
  Clients,
  Tags,
  ClientTags,
  PlanTemplates,
  ClientPlans,
  Attendance,
  AppSettings,
  Transactions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.forTesting(super.executor);

  static Future<AppDatabase> create() async {
    final executor = await connection.createExecutor();
return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Helper to safely add columns (idempotent - ignores "duplicate column" errors)
        Future<void> safeAddColumn(Migrator m, TableInfo table, GeneratedColumn column) async {
          try {
            await m.addColumn(table, column);
          } on Exception catch (e) {
            if (!e.toString().contains('duplicate column')) rethrow;
          }
        }

        if (from < 2) {
          await safeAddColumn(m, clientPlans, clientPlans.queueOrder);
        }
        if (from < 3) {
          await safeAddColumn(m, attendance, attendance.planId);
        }
        if (from < 4) {
          try {
            await m.createTable(transactions);
          } on Exception catch (e) {
            if (!e.toString().contains('already exists')) rethrow;
          }
        }
        if (from < 5) {
          await safeAddColumn(m, clientPlans, clientPlans.price);
          await safeAddColumn(m, clientPlans, clientPlans.sharePercent);
        }
        if (from < 6) {
          await safeAddColumn(m, transactions, transactions.planId);
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
  Future<List<ClientTag>> getAllClientTags() => select(clientTags).get();
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
  Future<List<ClientPlan>> getPlansUsingTemplate(int templateId) =>
      (select(clientPlans)..where((p) => p.templateId.equals(templateId))).get();

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
  /// Partial update of a single plan row.
  ///
  /// The previous implementations used `updatePlan(...replace(...))` with a
  /// full companion, which replaced the whole row: any column that was
  /// `Value.absent()` (e.g. `start_date`) fell back to its SQL default and
  /// was silently wiped whenever a session was consumed.
  Future<void> patchPlan(int planId, ClientPlansCompanion patch) =>
      (update(clientPlans)..where((p) => p.id.equals(planId))).write(patch);

  Future<void> updatePlanRemaining(int planId, int remaining) => patchPlan(
        planId,
        ClientPlansCompanion(remaining: Value(remaining)),
      );

  Future<void> updatePlanStatus(int planId, String status, {int? queueOrder}) => patchPlan(
        planId,
        ClientPlansCompanion(status: Value(status), queueOrder: Value(queueOrder)),
      );

  Future<void> clearPlanQueueOrder(int planId) => patchPlan(
        planId,
        ClientPlansCompanion(queueOrder: const Value(null)),
      );

Future<List<AttendanceData>> getClientAttendance(int clientId) => (select(attendance)..where((a) => a.clientId.equals(clientId))..orderBy([(a) => OrderingTerm.desc(a.date)])).get();
  Future<AttendanceData?> getAttendance(int clientId, String date) async {
    return (select(attendance)
          ..where((a) => a.clientId.equals(clientId) & a.date.equals(date))
          ..orderBy([(a) => OrderingTerm.desc(a.id)])
          ..limit(1))
        .getSingleOrNull();
  }
  Future<AttendanceData?> getPlanAttendanceForDate(int planId, String date) async {
    return (select(attendance)
          ..where((a) => a.planId.equals(planId) & a.date.equals(date))
          ..orderBy([(a) => OrderingTerm.desc(a.id)])
          ..limit(1))
        .getSingleOrNull();
  }
  Future<List<AttendanceData>> getPlanAttendance(int planId) => (select(attendance)..where((a) => a.planId.equals(planId))..orderBy([(a) => OrderingTerm.desc(a.date)])).get();
  Future<int> insertAttendance(AttendanceCompanion insert) => into(attendance).insert(insert);
  Future<bool> updateAttendance(AttendanceCompanion insert) => update(attendance).replace(insert);
  Future<int> deleteAttendance(int id) => (delete(attendance)..where((a) => a.id.equals(id))).go();
Future<int> addAttendance(AttendanceCompanion insert) => into(attendance).insert(insert);
  Future<AttendanceData?> getAttendanceById(int id) =>
      (select(attendance)..where((a) => a.id.equals(id))).getSingleOrNull();
  Stream<List<AttendanceData>> watchClientAttendance(int clientId) => (select(attendance)..where((a) => a.clientId.equals(clientId))..orderBy([(a) => OrderingTerm.desc(a.date)])).watch();
  Future<List<AttendanceData>> getAllAttendance() => select(attendance).get();

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

  Future<List<AppSetting>> getAllSettings() => select(appSettings).get();

  Future<List<Transaction>> getAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.id)])).get();
  Future<List<Transaction>> getClientTransactions(int clientId) =>
      (select(transactions)..where((t) => t.clientId.equals(clientId))..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.id)])).get();
  Future<Transaction?> getTransaction(int id) => (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTransaction(TransactionsCompanion insert) => into(transactions).insert(insert);
  Future<bool> updateTransaction(TransactionsCompanion insert) => update(transactions).replace(insert);
  Future<int> deleteTransaction(int id) => (delete(transactions)..where((t) => t.id.equals(id))).go();
  Future<int> deleteTransactionsForPlan(int planId) =>
      (delete(transactions)..where((t) => t.planId.equals(planId))).go();
}
