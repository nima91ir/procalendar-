import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';

class TagsService {
  final TagsRepository repository;
  TagsService(this.repository);

  Future<List<domain.Tag>> getAllTags() => repository.getAllTags();
  Future<int> createTag(String name, {String emoji = '', int color = 0xFF88A36B}) async {
    if (name.trim().isEmpty) throw ArgumentError('نام برچسب نمی‌تواند خالی باشد');
    return repository.insertTag(TagsCompanion.insert(
      name: name.trim(),
      emoji: Value(emoji),
      color: Value(color),
    ));
  }

  Future<void> updateTag(int id, String name, {String emoji = '', int color = 0xFF88A36B}) async {
    if (name.trim().isEmpty) throw ArgumentError('نام برچسب نمی‌تواند خالی باشد');
    await repository.updateTag(TagsCompanion.insert(
      id: Value(id),
      name: name.trim(),
      emoji: Value(emoji),
      color: Value(color),
    ));
  }

  Future<void> deleteTag(int id) async => repository.deleteTag(id);
  Future<void> assignTagToClient(int clientId, int tagId) => repository.assignTagToClient(clientId, tagId);
  Future<void> removeTagFromClient(int clientId, int tagId) => repository.removeTagFromClient(clientId, tagId);
  Future<List<int>> getClientTagIds(int clientId) => repository.getClientTagIds(clientId);
  Future<int> countClientsWithTag(int tagId) => repository.countClientsWithTag(tagId);
}
