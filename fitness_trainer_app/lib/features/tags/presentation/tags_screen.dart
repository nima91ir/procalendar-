import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/tags/presentation/widgets/tag_editor_dialog.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.navTags)),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (tags) {
          if (tags.isEmpty) {
            return AppEmptyState(icon: Icons.label_outline, title: s.noTagsDefined, subtitle: s.noTagsDefinedSubtitle);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
        final countAsync = ref.watch(tagUsageCountProvider(tag.id!));
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(tag.color),
                        child: Text(tag.emoji.isNotEmpty ? tag.emoji : tag.name[0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(tag.name, style: AppTypography.bodyLarge),
                      subtitle: Text(s.tagClientCount(countAsync.value ?? 0), style: AppTypography.bodySmall),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showEditDialog(context, tag),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(s.deleteTagTitle),
                                  content: Text(s.deleteTagMessage(tag.name)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.no)),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.yes)),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(tagsServiceProvider).deleteTag(tag.id!);
                                ref.invalidateAppData();
                              }
                            },
                            icon: Icon(Icons.delete_outline, color: t.error),
                          ),
                        ],
                      ),
                    ),
                  );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tagsFab',
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text(s.newTag),
      ),
    );
  }

  void _showAddDialog(BuildContext context) async {
    final newTag = await showTagEditorDialog(context, ref, callerRef: ref);
    if (newTag != null && context.mounted) {
      ref.invalidateAppData();
    }
  }

  void _showEditDialog(BuildContext context, dynamic tag) async {
    final updatedTag = await showTagEditorDialog(context, ref, existing: tag, callerRef: ref);
    if (updatedTag != null && context.mounted) {
      ref.invalidateAppData();
    }
  }
}

