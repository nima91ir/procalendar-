import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_repository.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(ref.watch(databaseProvider));
});

final clientsServiceProvider = Provider<ClientsService>((ref) {
  return ClientsService(ref.watch(clientsRepositoryProvider));
});

final clientsProvider = NotifierProvider<ClientsNotifier, List<domain.Client>>(() {
  return ClientsNotifier();
});

final allClientsProvider = FutureProvider.autoDispose<List<domain.Client>>((ref) {
  return ref.watch(clientsServiceProvider).getAllClients();
});

class ClientsNotifier extends Notifier<List<domain.Client>> {
  @override
  List<domain.Client> build() {
    return [];
  }

  Future<void> loadClients() async {
    final service = ref.read(clientsServiceProvider);
    state = await service.getAllClients();
  }

  Future<void> addClient(String name, {String? contact, String note = '', int bonusSessions = 0}) async {
    final service = ref.read(clientsServiceProvider);
    final id = await service.createClient(name, contact: contact, note: note, bonusSessions: bonusSessions);
    final newClient = domain.Client(name: name, contact: contact, note: note, bonusSessions: bonusSessions, id: id);
    state = [...state, newClient];
  }

  Future<void> updateClient(int id, String name, {String? contact, String note = '', int bonusSessions = 0}) async {
    final service = ref.read(clientsServiceProvider);
    await service.updateClient(id, name, contact: contact, note: note, bonusSessions: bonusSessions);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    final service = ref.read(clientsServiceProvider);
    await service.deleteClient(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<List<domain.Client>> searchClients(String query) async {
    final service = ref.read(clientsServiceProvider);
    return service.searchClients(query);
  }
}
