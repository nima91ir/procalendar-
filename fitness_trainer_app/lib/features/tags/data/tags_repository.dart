import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;

class TagsRepository {
  final AppDatabase db;
  TagsRepository(this.db);

  Future<List<domain.Tag>> getAllTags() async {
    final rows = await db.getAllTags();
    return rows.map((r) => domain.Tag(
      id: r.id,
      name: r.name,
      emoji: r.emoji,
      color: r.color,
    )).toList();
  }

  Future<domain.Tag?> getTag(int id) async {
    final row = await db.getTag(id);
    if (row == null) return null;
    return domain.Tag(
      id: row.id,
      name: row.name,
      emoji: row.emoji,
      color: row.color,
    );
  }

  Future<int> insertTag(TagsCompanion insert) => db.insertTag(insert);
  Future<bool> updateTag(TagsCompanion insert) => db.updateTag(insert);
  Future<int> deleteTag(int id) => db.deleteTag(id);
  Future<void> assignTagToClient(int clientId, int tagId) => db.assignTagToClient(clientId, tagId);
  Future<void> removeTagFromClient(int clientId, int tagId) => db.removeTagFromClient(clientId, tagId);
  Future<List<int>> getClientTagIds(int clientId) => db.getClientTagIds(clientId);
  Future<int> countClientsWithTag(int tagId) => db.countClientsWithTag(tagId);

  /// Every client↔tag link in a single query.
  ///
  /// Callers that need the links for *all* clients (the tag filters) used to
  /// await one `getClientTagIds` per client, which is an N+1 that re-ran on
  /// every mutation anywhere in the app.
  Future<List<({int clientId, int tagId})>> getAllClientTags() async {
    final rows = await db.getAllClientTags();
    return [for (final r in rows) (clientId: r.clientId, tagId: r.tagId)];
  }
}
