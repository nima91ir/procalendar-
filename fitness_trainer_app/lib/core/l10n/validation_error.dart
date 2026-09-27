/// Language-neutral keys for the business-rule failures a service can raise.
///
/// Services have no `BuildContext`, so they cannot resolve a localized
/// message. They used to hard-code Persian `ArgumentError`/`StateError` text,
/// which meant an English user saw a Persian error. They now throw a
/// [ValidationError] carrying one of these keys, and the UI renders it through
/// `AppStrings.validation(...)`, keeping the copy in the two const locales
/// where every other user-facing string already lives.
enum ValidationField {
  /// A client name was empty or whitespace only.
  clientName,

  /// The client row a plan/transaction referred to no longer exists.
  clientMissing,

  /// A tag name was empty or whitespace only.
  tagName,

  /// A template name was empty or whitespace only.
  templateName,

  /// A template's session or day count was zero or negative.
  templateCounts,
}

/// Thrown by a service when caller-supplied input fails a business rule.
///
/// The [field] is a key, not prose: it carries no user-facing text so it can
/// safely cross the data/ presentation boundary.
class ValidationError implements Exception {
  const ValidationError(this.field);

  /// Which rule failed, resolved to a message at the UI layer.
  final ValidationField field;

  @override
  String toString() => 'ValidationError(${field.name})';
}
