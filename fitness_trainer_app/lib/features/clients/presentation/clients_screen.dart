import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/clients/presentation/widgets/client_card.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

enum _SortMode { name, newest, bonus }

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _selectedTagId;
  _SortMode _sort = _SortMode.name;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Search is applied locally on top of the watched provider list, so the
  /// list also reflects any create/update/delete from anywhere in the app.
  void _onSearch(String query) => setState(() => _query = query);

  List<domain.Client> _applySort(List<domain.Client> clients) {
    final sorted = List<domain.Client>.of(clients);
    switch (_sort) {
      case _SortMode.name:
        sorted.sort((a, b) {
          final byName = a.name.compareTo(b.name);
          return byName != 0 ? byName : (a.id ?? 0).compareTo(b.id ?? 0);
        });
      case _SortMode.newest:
        sorted.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      case _SortMode.bonus:
        sorted.sort((a, b) {
          final byBonus = (b.bonusSessions).compareTo(a.bonusSessions);
          return byBonus != 0 ? byBonus : (a.id ?? 0).compareTo(b.id ?? 0);
        });
    }
    return sorted;
  }

  String _quickFilterLabel(ClientQuickFilter filter, AppStrings s) {
    switch (filter) {
      case ClientQuickFilter.all:
        return s.allLabel;
      case ClientQuickFilter.expired:
        return s.expiredPlans;
      case ClientQuickFilter.frozen:
        return s.frozenPlans;
      case ClientQuickFilter.queued:
        return s.queuedPlans;
      case ClientQuickFilter.lowSession:
        return s.lowSessionPlans;
      case ClientQuickFilter.bonus:
        return s.bonusSessions;
    }
  }

  Future<void> _deleteClient(domain.Client client) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: s.deleteClientTitle,
      message: s.deleteClientMessage(client.name),
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (confirmed && mounted) {
      await ref.read(clientsServiceProvider).deleteClient(client.id!);
      ref.invalidateAppData();
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(s.clientDeleted(client.name))));
      }
    }
  }

  /// Bottom-sheet quick actions for a client, opened by long-press or the
  /// card's ⋮ button. Tapping the card itself opens the client profile.
  void _showClientActions(domain.Client client) {
    final s = AppStrings.of(context);
    final t = context.tones;
    final clientId = client.id!;
    AppBottomSheet.show<void>(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
            child: Text(client.name, style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(s.openAttendance),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId');
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Text(s.quickAddToday, style: Theme.of(context).textTheme.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Consumer(
              builder: (context, ref, _) {
                final plans = ref.watch(clientPlansProvider(clientId));
                final activePlanId = plans.value?.where((p) => p.isActive).firstOrNull?.id;
                final notifier = ref.read(attendanceProvider.notifier);
                final today = jalaliToday();
                return Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          notifier.addSession(clientId, today, status: 'present', planId: activePlanId);
                        },
                        icon: const Icon(Icons.check),
                        label: Text(s.present),
                        style: FilledButton.styleFrom(backgroundColor: t.successSoft, foregroundColor: t.success),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          notifier.addSession(clientId, today, status: 'absent', planId: activePlanId);
                        },
                        icon: const Icon(Icons.close),
                        label: Text(s.absent),
                        style: FilledButton.styleFrom(backgroundColor: t.errorSoft, foregroundColor: t.error),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(s.editClient),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '${AppRoutes.editClient}/$clientId');
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: t.error),
            title: Text(s.deleteClient, style: TextStyle(color: t.error)),
            onTap: () {
              Navigator.pop(context);
              _deleteClient(client);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final tagsAsync = ref.watch(allTagsProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    final quickFilter = ref.watch(clientQuickFilterProvider);
    final quickFilterIdsAsync = ref.watch(quickFilterClientIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.clientsTitle),
        actions: [
          PopupMenuButton<_SortMode>(
            tooltip: s.sortBy,
            icon: const Icon(Icons.sort),
            onSelected: (mode) => setState(() => _sort = mode),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortMode.name,
                child: Row(children: [
                  Icon(Icons.sort_by_alpha, size: 18, color: _sort == _SortMode.name ? t.primary : null),
                  const SizedBox(width: AppSpacing.sm),
                  Text(s.sortName),
                ]),
              ),
              PopupMenuItem(
                value: _SortMode.newest,
                child: Row(children: [
                  Icon(Icons.new_releases_outlined, size: 18, color: _sort == _SortMode.newest ? t.primary : null),
                  const SizedBox(width: AppSpacing.sm),
                  Text(s.sortNewest),
                ]),
              ),
              PopupMenuItem(
                value: _SortMode.bonus,
                child: Row(children: [
                  Icon(Icons.card_giftcard, size: 18, color: _sort == _SortMode.bonus ? t.primary : null),
                  const SizedBox(width: AppSpacing.sm),
                  Text(s.sortBonus),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          tagsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(s.allLabel),
                          selected: _selectedTagId == null,
                          onSelected: (_) => setState(() => _selectedTagId = null),
                          selectedColor: t.primaryLight,
                          checkmarkColor: t.onSurface,
                        ),
                      );
                    }
                    final tag = tags[index - 1];
                    final isSelected = _selectedTagId == tag.id;
                    return Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedTagId = isSelected ? null : tag.id),
                        selectedColor: Color(tag.color),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          if (quickFilter != ClientQuickFilter.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Chip(
                  avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                  label: Text(_quickFilterLabel(quickFilter, s)),
                  onDeleted: () => ref.read(clientQuickFilterProvider.notifier).set(ClientQuickFilter.all),
                ),
              ),
            ),
          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppErrorState(message: error.toString()),
              data: (allClients) {
                final query = _query.trim();
                final searched = query.isEmpty
                    ? allClients
                    : allClients
                        .where((c) => c.name.contains(query) || (c.contact ?? '').contains(query))
                        .toList();
                final quickIds = quickFilterIdsAsync.value;
                final filtered = (quickFilter == ClientQuickFilter.all || quickIds == null)
                    ? searched
                    : searched.where((c) => quickIds.contains(c.id)).toList();
                final clients = _applySort(filtered);
                if (clients.isEmpty) {
                  return quickFilter != ClientQuickFilter.all
                      ? AppEmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: s.noResults,
                          subtitle: _quickFilterLabel(quickFilter, s),
                        )
                      : query.isEmpty
                          ? AppEmptyState(icon: Icons.people_outline, title: s.emptyClientsTitle, subtitle: s.emptyClientsSubtitle)
                          : AppEmptyState(icon: Icons.search_off, title: s.noResults, subtitle: s.noResultsSubtitle);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                      return Dismissible(
                        key: ValueKey(client.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: t.error,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: AppSpacing.lg),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await AppConfirmDialog.show(
                            context,
                            title: s.deleteClientTitle,
                            message: s.deleteClientMessage(client.name),
                            confirmLabel: s.delete,
                            cancelLabel: s.cancel,
                          );
                        },
                        onDismissed: (_) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ref.read(clientsServiceProvider).deleteClient(client.id!);
                          ref.invalidateAppData();
                          if (mounted) {
                            messenger.showSnackBar(SnackBar(content: Text(s.clientDeleted(client.name))));
                          }
                        },
                        child: ClientCard(
                          clientId: client.id!,
                          onTap: () => Navigator.pushNamed(context, '${AppRoutes.clientDetail}/${client.id}'),
                          onLongPress: () => _showClientActions(client),
                          onShowActions: () => _showClientActions(client),
                        ),
                      );
                    },
                  );
                },
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'clientsFab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addClient),
        icon: const Icon(Icons.add),
        label: Text(s.addClient),
      ),
    );
  }
}