import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<QueryExecutor> createExecutor() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final path = p.join(dbFolder.path, 'fitness_trainer.db');
  return LazyDatabase(() async {
    return NativeDatabase(File(path), setup: (db) async {
      db.execute('PRAGMA foreign_keys = ON');
    });
  });
}
