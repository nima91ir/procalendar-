import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;

class ClientsRepository {
  final AppDatabase db;
  ClientsRepository(this.db);

  Future<List<domain.Client>> getAllClients() async {
    final rows = await db.getAllClients();
    return rows.map((r) => domain.Client(
      id: r.id,
      name: r.name,
      contact: r.contact,
      note: r.note,
      bonusSessions: r.bonusSessions,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<domain.Client?> getClient(int id) async {
    final row = await db.getClient(id);
    if (row == null) return null;
    return domain.Client(
      id: row.id,
      name: row.name,
      contact: row.contact,
      note: row.note,
      bonusSessions: row.bonusSessions,
      createdAt: row.createdAt,
    );
  }

  Future<int> insertClient(ClientsCompanion insert) => db.insertClient(insert);
  Future<bool> updateClient(ClientsCompanion insert) => db.updateClient(insert);
  Future<int> deleteClient(int id) => db.deleteClient(id);

  Future<List<domain.Client>> searchClients(String query) async {
    final rows = await db.searchClients(query);
    return rows.map((r) => domain.Client(
      id: r.id,
      name: r.name,
      contact: r.contact,
      note: r.note,
      bonusSessions: r.bonusSessions,
      createdAt: r.createdAt,
    )).toList();
  }

  Stream<List<domain.Client>> watchAllClients() {
    return db.watchAllClients().map((rows) => rows.map((r) => domain.Client(
      id: r.id,
      name: r.name,
      contact: r.contact,
      note: r.note,
      bonusSessions: r.bonusSessions,
      createdAt: r.createdAt,
    )).toList());
  }

  Future<void> updateClientBonus(int clientId, int bonus) async {
    final client = await getClient(clientId);
    if (client != null) {
      await updateClient(ClientsCompanion.insert(
        id: Value(clientId),
        name: client.name,
        contact: client.contact != null ? Value(client.contact!) : const Value.absent(),
        note: Value(client.note),
        bonusSessions: Value(bonus),
      ));
    }
  }
}
