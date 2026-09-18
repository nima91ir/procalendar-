import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';

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
  final tags = await ref.read(allTagsProvider.future);
  if (!context.mounted) return null;

  final result = <int>{...selected};

  return showModalBottomSheet<Set<int>>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.tagsSection, style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  if (tags.isEmpty)
                    Text(s.noTagsDefined, style: AppTypography.bodySmall)
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
}
