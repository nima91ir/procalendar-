/// Row counts for one backup payload (used both as totals and as the number of
/// rows a merge actually added).
class BackupCounts {
  const BackupCounts({
    this.clients = 0,
    this.tags = 0,
    this.clientTags = 0,
    this.templates = 0,
    this.plans = 0,
    this.attendance = 0,
    this.settings = 0,
    this.transactions = 0,
  });

  final int clients;
  final int tags;
  final int clientTags;
  final int templates;
  final int plans;
  final int attendance;
  final int settings;
  final int transactions;

  int get total =>
      clients + tags + clientTags + templates + plans + attendance + settings + transactions;

  bool get isEmpty => total == 0;
}

/// How a JSON backup is applied to the current database.
enum BackupImportMode {
  /// Add rows that are not already present (by id); never overwrites.
  merge,

  /// Delete everything and restore the backup exactly.
  replace,
}

class BackupImportResult {
  const BackupImportResult({
    required this.mode,
    required this.added,
    required this.total,
  });

  final BackupImportMode mode;

  /// Rows actually written (for [BackupImportMode.replace] this equals [total]).
  final BackupCounts added;

  /// Rows contained in the backup file.
  final BackupCounts total;
}
