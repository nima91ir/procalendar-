import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/reports/data/reports_service.dart';

void main() {
  group('ReportsService', () {
    late AppDatabase db;
    late ReportsService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory(setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');
      }));
      service = ReportsService();
    });

    tearDown(() async {
      await db.close();
    });

    TransactionEntry entry({
      int? clientId,
      String type = TransactionTypes.income,
      String category = TransactionCategories.plan,
      int amount = 100000,
      String date = '1405/06/27',
    }) =>
        TransactionEntry(
          clientId: clientId,
          type: type,
          category: category,
          amount: amount,
          date: date,
        );

    test('totalsBetween includes boundaries', () {
      final txs = [
        entry(amount: 100, date: '1405/06/01'),
        entry(amount: 200, date: '1405/06/15'),
        entry(amount: 300, date: '1405/06/30'),
        entry(amount: 400, date: '1405/07/01'),
      ];
      final totals = service.totalsBetween(txs,
          startKey: '1405/06/15', endKey: '1405/06/30');
      expect(totals.income, 500); // 200 + 300
      expect(totals.expense, 0);
    });

    test('totalsBetween separates income and expense', () {
      final txs = [
        entry(amount: 1000, date: '1405/06/10'),
        entry(amount: 200, date: '1405/06/12', type: TransactionTypes.expense),
        entry(amount: 500, date: '1405/06/20'),
      ];
      final totals = service.totalsBetween(txs,
          startKey: '1405/06/01', endKey: '1405/06/30');
      expect(totals.income, 1500);
      expect(totals.expense, 200);
      expect(totals.balance, 1300);
    });

    test('monthlyBuckets returns count buckets oldest-to-newest, current flagged', () {
      final now = Jalali.fromDateTime(DateTime.now());
      final thisMonth = '${now.year}/${now.month.toString().padLeft(2, '0')}';
      final lastMonth = (now.month == 1)
          ? '${now.year - 1}/12'
          : '${now.year}/${(now.month - 1).toString().padLeft(2, '0')}';
      final txs = [
        entry(amount: 100, date: '$lastMonth/15'),
        entry(amount: 200, date: '$thisMonth/05'),
        entry(amount: 300, date: '$thisMonth/20'),
      ];
      final buckets = service.monthlyBuckets(txs, count: 2);
      expect(buckets.length, 2);
      expect(buckets[0].key.startsWith(lastMonth), true);
      expect(buckets[0].isCurrent, false);
      expect(buckets[0].income, 100);
      expect(buckets[1].key.startsWith(thisMonth), true);
      expect(buckets[1].isCurrent, true);
      expect(buckets[1].income, 500);
    });

    test('dailyBuckets returns count buckets oldest-to-newest, today flagged', () {
      final txs = [
        entry(amount: 100, date: '1405/06/26'),
        entry(amount: 200, date: '1405/06/27'),
      ];
      final anchor = Jalali(1405, 6, 27);
      final buckets = service.dailyBuckets(txs, count: 2, anchor: anchor);
      expect(buckets.length, 2);
      expect(buckets[0].key, '1405/06/26');
      expect(buckets[0].isCurrent, false);
      expect(buckets[1].key, '1405/06/27');
      expect(buckets[1].isCurrent, true);
    });

    test('dailyBuckets aggregates expense too', () {
      final txs = [
        entry(amount: 100, date: '1405/06/27'),
        entry(amount: 50, date: '1405/06/27', type: TransactionTypes.expense),
      ];
      final anchor = Jalali(1405, 6, 27);
      final buckets = service.dailyBuckets(txs, count: 1, anchor: anchor);
      expect(buckets.single.income, 100);
      expect(buckets.single.expense, 50);
    });
  });
}