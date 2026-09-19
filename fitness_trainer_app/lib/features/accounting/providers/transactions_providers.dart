import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/accounting/data/transactions_service.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseProvider));
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    ref.watch(transactionRepositoryProvider),
    ref.watch(databaseProvider),
  );
});

/// Every ledger row, newest date/id first.
final transactionsProvider = FutureProvider.autoDispose<List<TransactionEntry>>((ref) {
  return ref.watch(transactionServiceProvider).getAllTransactions();
});

/// A client's ledger rows (used on the client detail screen).
final clientTransactionsProvider =
    FutureProvider.autoDispose.family<List<TransactionEntry>, int>((ref, clientId) {
  return ref.watch(transactionServiceProvider).getClientTransactions(clientId);
});