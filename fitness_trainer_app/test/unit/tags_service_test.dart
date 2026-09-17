import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_repository.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = await Directory.systemTemp.createTemp('fitness_test_');
  final path = p.join(tempDir.path, 'test.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
  group('Tags Service', () {
    late AppDatabase db;
    late TagsRepository tagsRepository;
    late TagsService tagsService;

    setUp(() async {
      db = await createTestDb();
      tagsRepository = TagsRepository(db);
      tagsService = TagsService(tagsRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTag inserts tag', () async {
      final id = await tagsService.createTag('VIP');
      expect(id, greaterThan(0));
      final tag = await db.getTag(id);
      expect(tag!.name, 'VIP');
    });

    test('createTag rejects empty name', () async {
      expect(() => tagsService.createTag(''), throwsA(isA<ArgumentError>()));
    });

    test('updateTag modifies existing tag', () async {
      final id = await tagsService.createTag('Old', emoji: '⭐');
      await tagsService.updateTag(id, 'New', emoji: '🌟', color: 0xFFFF0000);
      final tag = await db.getTag(id);
      expect(tag!.name, 'New');
      expect(tag.emoji, '🌟');
      expect(tag.color, 0xFFFF0000);
    });

    test('deleteTag removes tag', () async {
      final id = await tagsService.createTag('ToDelete');
      expect(await db.getTag(id), isNotNull);
      await tagsService.deleteTag(id);
      expect(await db.getTag(id), isNull);
    });

    test('assignTagToClient and removeTagFromClient', () async {
      final tagId = await tagsService.createTag('VIP');
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Client'));
      await tagsService.assignTagToClient(clientId, tagId);
      final clientTags = await db.getClientTagIds(clientId);
      expect(clientTags, [tagId]);
      await tagsService.removeTagFromClient(clientId, tagId);
      final afterRemove = await db.getClientTagIds(clientId);
      expect(afterRemove, isEmpty);
    });

    test('countClientsWithTag returns correct count', () async {
      final tagId = await tagsService.createTag('VIP');
      final clientId = await db.insertClient(ClientsCompanion.insert(name: 'Client'));
      await tagsService.assignTagToClient(clientId, tagId);
      expect(await tagsService.countClientsWithTag(tagId), 1);
    });
  });
}
