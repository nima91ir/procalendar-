import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepository(ref.watch(databaseProvider));
});

final tagsServiceProvider = Provider<TagsService>((ref) {
  return TagsService(ref.watch(tagsRepositoryProvider));
});

final tagsProvider = NotifierProvider<TagsNotifier, List<domain.Tag>>(() {
  return TagsNotifier();
});

final allTagsProvider = FutureProvider.autoDispose<List<domain.Tag>>((ref) {
  return ref.watch(tagsServiceProvider).getAllTags();
});

class TagsNotifier extends Notifier<List<domain.Tag>> {
  @override
  List<domain.Tag> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final service = ref.read(tagsServiceProvider);
    state = await service.getAllTags();
  }

  Future<void> addTag(String name, {String emoji = '', int color = 0xFF88A36B}) async {
    final service = ref.read(tagsServiceProvider);
    final id = await service.createTag(name, emoji: emoji, color: color);
    state = [...state, domain.Tag(id: id, name: name, emoji: emoji, color: color)];
  }

  Future<void> updateTag(int id, String name, {String emoji = '', int color = 0xFF88A36B}) async {
    final service = ref.read(tagsServiceProvider);
    await service.updateTag(id, name, emoji: emoji, color: color);
    await _load();
  }

  Future<void> deleteTag(int id) async {
    final service = ref.read(tagsServiceProvider);
    await service.deleteTag(id);
    state = state.where((t) => t.id != id).toList();
  }
}
