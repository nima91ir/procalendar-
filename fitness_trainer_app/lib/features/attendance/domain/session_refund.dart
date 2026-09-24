/// Where the session of a removed attendance record ended up.
///
/// Removing a record refunds the session it consumed, but the refund can
/// legitimately land somewhere other than the plan it came from (an expired
/// plan's successor, or a bonus session). The UI reports this instead of
/// silently changing counters — a removal that used to look like "attendance
/// got mixed with bonus sessions" now says exactly what happened.
enum SessionRefund {
  /// Returned to a plan (the recorded one, or the active successor).
  plan,

  /// Restored as a bonus session.
  bonus,

  /// Nothing was refunded: the record consumed nothing, or its session had
  /// nowhere to go.
  none,
}

/// A removal's outcome: which client the record belonged to, and where the
/// refunded session landed.
typedef SessionRemoval = ({int clientId, SessionRefund refund});
