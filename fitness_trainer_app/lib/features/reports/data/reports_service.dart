import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/reports/domain/report_models.dart';

/// Pure, testable report computations over the transaction ledger.
///
/// Dates are stored as zero-padded Jalali `yyyy/MM/dd` keys, so plain string
/// comparison orders them correctly and `startsWith` slices a bucket.
class ReportsService {
  /// Totals for every transaction whose date falls inside the inclusive range
  /// [`startKey`, `endKey`] (Jalali `yyyy/MM/dd`).
  PeriodTotals totalsBetween(
    List<TransactionEntry> transactions, {
    required String startKey,
    required String endKey,
  }) {
    var income = 0;
    var expense = 0;
    for (final tx in transactions) {
      final inRange = tx.date.compareTo(startKey) >= 0 &&
          tx.date.compareTo(endKey) <= 0;
      if (!inRange) continue;
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return PeriodTotals(income, expense);
  }

  /// The last [count] Jalali months, oldest first, ending with the current
  /// month (flagged `isCurrent`).
  List<JalaliBucket> monthlyBuckets(
    List<TransactionEntry> transactions, {
    int count = 12,
  }) {
    final now = Jalali.fromDateTime(DateTime.now());
    final currentIndex = now.year * 12 + (now.month - 1);
    final buckets = <(int year, int month)>[];
    for (var k = count - 1; k >= 0; k--) {
      final index = currentIndex - k;
      buckets.add((index ~/ 12, index % 12 + 1));
    }
    return [
      for (final (year, month) in buckets)
        _bucket(
          transactions,
          prefix: '$year/${month.toString().padLeft(2, '0')}',
          isCurrent: year == now.year && month == now.month,
        ),
    ];
  }

  /// The last [count] days, oldest first, ending with [anchor] (defaults to today).
  List<JalaliBucket> dailyBuckets(
    List<TransactionEntry> transactions, {
    int count = 7,
    Jalali? anchor,
  }) {
    anchor ??= Jalali.fromDateTime(DateTime.now());
    final buckets = <(String key, bool isCurrent)>[];
    for (var k = count - 1; k >= 0; k--) {
      final day = anchor.addDays(-k);
      buckets.add((
        '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}',
        k == 0,
      ));
    }
    return [
      for (final (key, isCurrent) in buckets)
        _bucket(transactions, prefix: key, isCurrent: isCurrent),
    ];
  }

  JalaliBucket _bucket(
    List<TransactionEntry> transactions, {
    required String prefix,
    required bool isCurrent,
  }) {
    var income = 0;
    var expense = 0;
    for (final tx in transactions) {
      if (!tx.date.startsWith(prefix)) continue;
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return JalaliBucket(
      key: prefix,
      income: income,
      expense: expense,
      isCurrent: isCurrent,
    );
  }
}