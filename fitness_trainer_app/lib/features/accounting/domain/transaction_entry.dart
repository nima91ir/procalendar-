/// One money movement in the accounting ledger.
///
/// `type` is either `income` or `expense` ([TransactionTypes]); `category`
/// narrows it down (see [TransactionCategories]). `amount` is stored in toman
/// as an integer. `date` is the Jalali `yyyy/MM/dd` string the trainer picked
/// (defaults to today), independent of `createdAt`.
class TransactionEntry {
  const TransactionEntry({
    this.id,
    this.clientId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
    this.createdAt = '',
  });

  final int? id;
  final int? clientId;
  final String type;
  final String category;
  final int amount;
  final String date;
  final String note;
  final String createdAt;

  bool get isIncome => type == TransactionTypes.income;
}

class TransactionTypes {
  static const income = 'income';
  static const expense = 'expense';
}

/// Flat category keys shared by both types; labels come from
/// `AppStrings.transactionCategory`.
class TransactionCategories {
  static const plan = 'plan';
  static const other = 'other';
  static const rent = 'rent';
  static const salary = 'salary';
  static const equipment = 'equipment';

  static const income = [plan, other];
  static const expense = [rent, salary, equipment, other];
}