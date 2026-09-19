import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/tags/presentation/widgets/tag_editor_dialog.dart';

/// Bottom sheet that lets the user toggle which tags are assigned to a client.
///
/// Returns the new set of selected tag ids, or `null` if dismissed. The caller
/// decides how to persist the change (a form keeps it local until save, the
/// client detail screen writes it immediately).
Future<Set<int>?> showClientTagPicker(
  BuildContext context,
  WidgetRef ref,
  Set<int> selected,
) async {
  final s = AppStrings.of(context);
  final result = <int>{...selected};

  return showModalBottomSheet<Set<int>>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final tagsAsync = ref.watch(allTagsProvider);

          return tagsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorState(message: e.toString()),
            data: (tags) {
              return StatefulBuilder(
                builder: (context, setSheetState) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.tagsSection, style: AppTypography.titleLarge),
                              TextButton.icon(
                                onPressed: () async {
                                  final newTag = await showTagEditorDialog(context, ref);
                                  if (newTag != null && context.mounted) {
                                    setSheetState(() => result.add(newTag.id!));
                                  }
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(s.addTag),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (tags.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(s.noTagsDefined, style: AppTypography.bodySmall),
                                    const SizedBox(height: AppSpacing.md),
                                    FilledButton.icon(
                                      onPressed: () async {
                                        final newTag = await showTagEditorDialog(context, ref);
                                        if (newTag != null && context.mounted) {
                                          setSheetState(() => result.add(newTag.id!));
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text(s.addTag),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final tag in tags)
                                  FilterChip(
                                    label: Text(tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name),
                                    selected: result.contains(tag.id),
                                    onSelected: (on) => setSheetState(() {
                                      if (on) {
                                        result.add(tag.id!);
                                      } else {
                                        result.remove(tag.id);
                                      }
                                    }),
                                  ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.lg),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(sheetContext, result),
                              child: Text(s.save),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}