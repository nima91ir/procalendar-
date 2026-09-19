import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';

class TransactionRepository {
  final AppDatabase db;
  TransactionRepository(this.db);

  Future<List<TransactionEntry>> getAll() async {
    final rows = await db.getAllTransactions();
    return rows.map(_map).toList();
  }

  Future<List<TransactionEntry>> forClient(int clientId) async {
    final rows = await db.getClientTransactions(clientId);
    return rows.map(_map).toList();
  }

  Future<int> add(TransactionEntry entry) => db.insertTransaction(
        TransactionsCompanion.insert(
          clientId: Value(entry.clientId),
          type: entry.type,
          category: entry.category,
          amount: entry.amount,
          date: entry.date,
          note: Value(entry.note),
        ),
      );

  Future<bool> update(TransactionEntry entry) => db.updateTransaction(
        TransactionsCompanion(
          id: Value(entry.id!),
          clientId: Value(entry.clientId),
          type: Value(entry.type),
          category: Value(entry.category),
          amount: Value(entry.amount),
          date: Value(entry.date),
          note: Value(entry.note),
        ),
      );

  Future<int> delete(int id) => db.deleteTransaction(id);

  static TransactionEntry _map(Transaction row) => TransactionEntry(
        id: row.id,
        clientId: row.clientId,
        type: row.type,
        category: row.category,
        amount: row.amount,
        date: row.date,
        note: row.note,
        createdAt: row.createdAt,
      );
}

class TransactionService {
  TransactionService(this.repository, this.db);

  final TransactionRepository repository;
  final AppDatabase db;

  Future<List<TransactionEntry>> getAllTransactions() => repository.getAll();
  Future<List<TransactionEntry>> getClientTransactions(int clientId) =>
      repository.forClient(clientId);

  Future<int> addTransaction(TransactionEntry entry) => repository.add(entry);
  Future<bool> updateTransaction(TransactionEntry entry) => repository.update(entry);
  Future<int> deleteTransaction(int id) => repository.delete(id);

  /// Sums of every transaction in the ledger, in toman.
  Future<({int income, int expense})> getTotals() async {
    final rows = await repository.getAll();
    var income = 0;
    var expense = 0;
    for (final row in rows) {
      if (row.isIncome) {
        income += row.amount;
      } else {
        expense += row.amount;
      }
    }
    return (income: income, expense: expense);
  }

  /// The share of [income] that belongs elsewhere for a given percentage
  /// (`sharePercent`, 0-100), rounded down. Pure helper used by the accounting
  /// summary and tests; the share now lives on each plan rather than as a
  /// global workbook setting.
  int gymShare(int income, int sharePercent) => (income * sharePercent) ~/ 100;

  /// Remaining balance after the share is deducted: income minus the share
  /// minus expense.
  int netIncome(int income, int expense, int sharePercent) =>
      income - gymShare(income, sharePercent) - expense;
}