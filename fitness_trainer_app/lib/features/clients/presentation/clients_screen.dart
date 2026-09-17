import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();
  List<domain.Client> _displayedClients = [];
  int? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    final clients = await ref.read(clientsServiceProvider).getAllClients();
    setState(() => _displayedClients = clients);
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      final clients = await ref.read(clientsServiceProvider).getAllClients();
      setState(() => _displayedClients = clients);
    } else {
      final clients = await ref.read(clientsServiceProvider).searchClients(query);
      setState(() => _displayedClients = clients);
    }
  }

  Future<void> _deleteClient(domain.Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف مشتری'),
        content: Text('آیا از حذف "${client.name}" اطمینان دارید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('بله')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(clientsServiceProvider).deleteClient(client.id!);
      _loadClients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${client.name} حذف شد')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مشتریان')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'جستجوی مشتری...',
                prefixIcon: Icon(Icons.search),
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
                          label: const Text('همه'),
                          selected: _selectedTagId == null,
                          onSelected: (_) => setState(() => _selectedTagId = null),
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.onSurface,
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
          Expanded(
            child: _displayedClients.isEmpty
                ? const AppEmptyState(icon: Icons.people_outline, title: 'هنوز مشتری‌ای اضافه نشده', subtitle: 'برای شروع اولین مشتری را اضافه کنید')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: _displayedClients.length,
                    itemBuilder: (context, index) {
                      final client = _displayedClients[index];
                      return Dismissible(
                        key: ValueKey(client.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: AppSpacing.lg),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('حذف مشتری'),
                              content: Text('آیا از حذف "${client.name}" اطمینان دارید؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('بله')),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          ref.read(clientsServiceProvider).deleteClient(client.id!);
                          setState(() => _displayedClients = _displayedClients.where((c) => c.id != client.id).toList());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${client.name} حذف شد')));
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(client.name[0], style: const TextStyle(color: AppColors.onSurface, fontSize: 18)),
                            ),
                            title: Text(client.name, style: AppTypography.bodyLarge),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (client.contact != null && client.contact!.isNotEmpty)
                                  Text(client.contact!, style: AppTypography.bodySmall),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.card_giftcard, size: 14, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text('${client.bonusSessions} جلسه اضافه', style: AppTypography.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _deleteClient(client),
                            ),
onTap: () async {
  await Navigator.pushNamed(context, '${AppRoutes.clientDetail}/${client.id}');
  if (mounted) {
    _loadClients();
  }
},
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    final result = await Navigator.pushNamed(context, AppRoutes.addClient);
    if (result == true && mounted) {
      _loadClients();
    }
  },
        icon: const Icon(Icons.add),
        label: const Text('افزودن مشتری'),
      ),
    );
  }
}
