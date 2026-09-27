import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/accounting/data/transactions_service.dart';
import 'package:fitness_trainer_app/features/accounting/domain/accounting_period.dart';
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

/// Reporting window selected on the accounting screen.
///
/// Screen-local state, not a saved preference: it is a lens you switch while
/// reading, and it resets to the full picture each time you open the screen.
class AccountingPeriodNotifier extends Notifier<AccountingPeriod> {
  @override
  AccountingPeriod build() => AccountingPeriod.lifetime;

  void set(AccountingPeriod period) {
    if (period == state) return;
    state = period;
  }
}

final accountingPeriodProvider =
    NotifierProvider<AccountingPeriodNotifier, AccountingPeriod>(AccountingPeriodNotifier.new);

/// A client's ledger rows (used on the client detail screen).
final clientTransactionsProvider =
    FutureProvider.autoDispose.family<List<TransactionEntry>, int>((ref, clientId) {
  return ref.watch(transactionServiceProvider).getClientTransactions(clientId);
});