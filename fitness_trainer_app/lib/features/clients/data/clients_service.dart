import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';

class ClientsService {
  final ClientsRepository repository;
  ClientsService(this.repository);

  Future<List<domain.Client>> getAllClients() => repository.getAllClients();
  Future<domain.Client?> getClient(int id) => repository.getClient(id);

  Future<int> createClient(String name, {String? contact, String note = '', int bonusSessions = 0}) async {
    if (name.trim().isEmpty) throw ArgumentError('نام مشتری نمی‌تواند خالی باشد');
    return repository.insertClient(ClientsCompanion.insert(
      name: name.trim(),
      contact: contact?.trim().isNotEmpty == true ? Value(contact!.trim()) : const Value.absent(),
      note: Value(note),
      bonusSessions: Value(bonusSessions),
    ));
  }

  Future<void> updateClient(int id, String name, {String? contact, String note = '', int bonusSessions = 0}) async {
    if (name.trim().isEmpty) throw ArgumentError('نام مشتری نمی‌تواند خالی باشد');
    final existing = await repository.getClient(id);
    if (existing == null) throw StateError('مشتری یافت نشد');
    await repository.updateClient(ClientsCompanion.insert(
      id: Value(id),
      name: name.trim(),
      contact: contact?.trim().isNotEmpty == true ? Value(contact!.trim()) : const Value.absent(),
      note: Value(note),
      bonusSessions: Value(bonusSessions),
    ));
  }

  Future<void> deleteClient(int id) async => repository.deleteClient(id);

  Future<List<domain.Client>> searchClients(String query) async {
    if (query.trim().isEmpty) return repository.getAllClients();
    return repository.searchClients(query.trim());
  }
}
