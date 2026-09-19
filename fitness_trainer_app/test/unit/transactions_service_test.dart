import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/accounting/data/transactions_service.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late TransactionRepository repository;
  late TransactionService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    }));
    repository = TransactionRepository(db);
    service = TransactionService(repository, db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addClient(String name) => db.insertClient(
        ClientsCompanion.insert(name: name),
      );

  TransactionEntry entry({
    int? clientId,
    String type = TransactionTypes.income,
    String category = TransactionCategories.plan,
    int amount = 100000,
    String date = '1405/06/27',
    String note = '',
  }) =>
      TransactionEntry(
        clientId: clientId,
        type: type,
        category: category,
        amount: amount,
        date: date,
        note: note,
      );

  test('add and list transactions, newest date/id first', () async {
    final clientId = await addClient('سارا');
    await service.addTransaction(entry(clientId: clientId, date: '1405/06/01'));
    await service.addTransaction(entry(clientId: clientId, date: '1405/06/27'));
    await service.addTransaction(entry(clientId: clientId, date: '1405/06/27'));

    final all = await service.getAllTransactions();
    expect(all.length, 3);
    expect(all.first.date, '1405/06/27');
    expect(all.last.date, '1405/06/01');
    // Same-date rows sort newest id first so a re-added row appears on top.
    expect(all[0].id!.compareTo(all[1].id!), greaterThan(0));
  });

  test('getTotals sums income and expense separately', () async {
    await service.addTransaction(entry(amount: 300000));
    await service.addTransaction(entry(amount: 200000));
    await service.addTransaction(entry(
      type: TransactionTypes.expense,
      category: TransactionCategories.rent,
      amount: 150000,
    ));

    final totals = await service.getTotals();
    expect(totals.income, 500000);
    expect(totals.expense, 150000);
  });

  test('gymShare and netIncome use the configured percent, rounded down', () {
    expect(service.gymShare(1000000, 30), 300000);
    expect(service.gymShare(9999, 50), 4999);
    expect(service.netIncome(1000000, 150000, 30), 550000);
  });

  test('delete removes exactly the given row', () async {
    final id1 = await service.addTransaction(entry(amount: 100000));
    final id2 = await service.addTransaction(entry(amount: 50000));
    expect(await service.deleteTransaction(id1), 1);
    final all = await service.getAllTransactions();
    expect(all.single.id, id2);
  });

  test('update modifies an existing row in place', () async {
    final clientId = await addClient('مریم');
    final id = await service.addTransaction(entry(clientId: clientId, amount: 100000));

    final updated = TransactionEntry(
      id: id,
      clientId: null,
      type: TransactionTypes.expense,
      category: TransactionCategories.equipment,
      amount: 350000,
      date: '1405/06/28',
      note: 'دمبل',
    );
    expect(await service.updateTransaction(updated), isTrue);
    final stored = (await service.getAllTransactions()).single;
    expect(stored.clientId, isNull);
    expect(stored.isIncome, isFalse);
    expect(stored.amount, 350000);
    expect(stored.note, 'دمبل');
  });

  test('getClientTransactions filters by client', () async {
    final ali = await addClient('علی');
    final sara = await addClient('سارا');
    await service.addTransaction(entry(clientId: ali, amount: 100000));
    await service.addTransaction(entry(clientId: sara, amount: 200000));
    await service.addTransaction(entry(amount: 300000));

    final forSara = await service.getClientTransactions(sara);
    expect(forSara.single.amount, 200000);
    final forAli = await service.getClientTransactions(ali);
    expect(forAli.single.amount, 100000);
  });

  test('deleting a client nulls the client link but keeps the row', () async {
    final clientId = await addClient('سارا');
    await service.addTransaction(entry(clientId: clientId, amount: 100000));
    await db.deleteClient(clientId);

    final all = await service.getAllTransactions();
    expect(all.single.amount, 100000);
    expect(all.single.clientId, isNull);
  });

}