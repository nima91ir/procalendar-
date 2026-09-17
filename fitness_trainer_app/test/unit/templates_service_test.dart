import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_repository.dart';

Future<AppDatabase> createTestDb() async {
  final tempDir = await Directory.systemTemp.createTemp('fitness_test_');
  final path = p.join(tempDir.path, 'test.db');
  return AppDatabase.forTesting(NativeDatabase(File(path), setup: (db) {
    db.execute('PRAGMA foreign_keys = ON');
  }));
}

void main() {
  group('Templates Service', () {
    late AppDatabase db;
    late TemplatesRepository templatesRepository;
    late TemplatesService templatesService;

    setUp(() async {
      db = await createTestDb();
      templatesRepository = TemplatesRepository(db);
      templatesService = TemplatesService(templatesRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTemplate inserts template', () async {
      final id = await templatesService.createTemplate('Full Body', 3, 7);
      expect(id, greaterThan(0));
      final template = await db.getTemplate(id);
      expect(template!.name, 'Full Body');
      expect(template.sessions, 3);
      expect(template.days, 7);
    });

    test('createTemplate rejects empty name', () async {
      expect(() => templatesService.createTemplate('', 3, 7), throwsA(isA<ArgumentError>()));
    });

    test('createTemplate rejects non-positive sessions or days', () async {
      expect(() => templatesService.createTemplate('Test', 0, 7), throwsA(isA<ArgumentError>()));
      expect(() => templatesService.createTemplate('Test', 3, 0), throwsA(isA<ArgumentError>()));
    });

    test('updateTemplate modifies existing template', () async {
      final id = await templatesService.createTemplate('Old', 3, 7);
      await templatesService.updateTemplate(id, 'New', 4, 10);
      final template = await db.getTemplate(id);
      expect(template!.name, 'New');
      expect(template.sessions, 4);
      expect(template.days, 10);
    });

    test('deleteTemplate removes template', () async {
      final id = await templatesService.createTemplate('ToDelete', 3, 7);
      expect(await db.getTemplate(id), isNotNull);
      await templatesService.deleteTemplate(id);
      expect(await db.getTemplate(id), isNull);
    });
  });
}
