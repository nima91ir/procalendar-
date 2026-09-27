import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the currently selected bottom-navigation tab.
///
/// Hoisted out of `MainShell` so any screen can switch tabs. Previously the
/// dashboard tried `Navigator.pushNamed('/clients')`, but `/clients` has no
/// `AppRouter.onGenerateRoute` branch, so the route never resolved.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index == state) return;
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(() => TabIndexNotifier());

/// Asks for a tab to be shown at its *root* screen instead of wherever that
/// tab was last left.
///
/// Every tab keeps its own navigation stack (see `MainShell`), which is what
/// lets you switch away from a client profile and come back to it. That is the
/// right behaviour for a tab tap — but not for a drill-down. Tapping
/// "clients with bonus sessions" on the dashboard means "show me that list",
/// and before this the Clients tab still had the profile on top, so the user
/// landed back on the profile they had been reading.
///
/// Bumping [request] asks `MainShell` to clear the current tab's stack. A plain
/// tab tap deliberately does not use this.
class TabRootRequestNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Bumped (never read as a value) to request the reset.
  void request() => state++;
}

final tabRootRequestProvider =
    NotifierProvider<TabRootRequestNotifier, int>(TabRootRequestNotifier.new);

/// Quick filters applied to the client list.
///
/// Originally these were only reachable from the dashboard stat cards, while
/// the actual work happens on the Clients page — so the page could show you a
/// filter but never let you choose one. They are chosen on the Clients page now.
///
/// The time-based ones all answer "who needs me now?". With no schedule stored
/// anywhere, how recently somebody came in is the only honest signal for who is
/// likely to come in, so that is what they use.
enum ClientQuickFilter {
  all,

  /// Nobody has recorded them today yet — the trainer's daily list.
  notMarkedToday,

  /// Last visit was two weeks ago or more, so they are drifting away.
  stale,

  /// On the books but never once attended.
  neverAttended,

  /// Sessions nearly gone.
  lowSession,

  /// No running plan, so nothing can consume a session.
  noActivePlan,

  /// The running plan runs out of days within a week.
  expiringSoon,

  /// Sessions nearly gone, no running plan, or about to run out — the three
  /// reasons a plan conversation is due.
  ///
  /// Deliberately *excludes* "has an expired plan": almost every long-standing
  /// client has one, so matching on it would return nearly everybody and mean
  /// nothing.
  needsAttention,

  expired,
  frozen,
  queued,
  bonus,
}

class ClientQuickFilterNotifier extends Notifier<ClientQuickFilter> {
  @override
  ClientQuickFilter build() => ClientQuickFilter.all;

  void set(ClientQuickFilter filter) {
    if (filter == state) return;
    state = filter;
  }
}

final clientQuickFilterProvider =
    NotifierProvider<ClientQuickFilterNotifier, ClientQuickFilter>(() => ClientQuickFilterNotifier());
