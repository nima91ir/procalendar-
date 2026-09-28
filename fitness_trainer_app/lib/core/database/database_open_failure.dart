/// Thrown when the app cannot reach the storage that holds the user's data.
///
/// A failed launch is the *good* outcome here. The alternative is what actually
/// happened to a live user: the web build silently falls back to a database
/// kept in memory only, the app looks completely normal with an empty dataset,
/// and the coach starts re-entering clients — every one of those writes gone the
/// moment the app closes, while the real database sits untouched on the device.
class PersistentStorageUnavailable implements Exception {
  const PersistentStorageUnavailable(this.reason);

  /// What the browser reported, for the debug log. Never shown to the user:
  /// names like `sharedWorkers` mean nothing to them.
  final String reason;

  @override
  String toString() => 'PersistentStorageUnavailable: $reason';
}
