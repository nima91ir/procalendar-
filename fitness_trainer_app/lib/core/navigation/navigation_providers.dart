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

/// Cross-screen quick filters applied to the client list, used by the
/// dashboard stat cards to drill down into the underlying clients.
enum ClientQuickFilter { all, expired, frozen, queued, lowSession, bonus }

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
