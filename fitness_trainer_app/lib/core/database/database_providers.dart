import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/connection/shared.dart';

final _databaseFutureProvider = FutureProvider<AppDatabase>((ref) async {
  final executor = await createExecutor();
  return AppDatabase(executor);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(_databaseFutureProvider).requireValue;
});
