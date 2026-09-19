/// Income/expense/balance for a time window, in toman.
class PeriodTotals {
  final int income;
  final int expense;

  const PeriodTotals(this.income, this.expense);

  int get balance => income - expense;
}

/// One bucket of a Jalali time series (a month or a day). `key` is the
/// `yyyy/MM` (month) or `yyyy/MM/dd` (day) prefix used to group transactions.
class JalaliBucket {
  final String key;
  final int income;
  final int expense;
  final bool isCurrent;

  const JalaliBucket({
    required this.key,
    required this.income,
    required this.expense,
    required this.isCurrent,
  });
}