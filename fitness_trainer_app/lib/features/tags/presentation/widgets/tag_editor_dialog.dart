import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;

/// Shared create/edit tag editor used everywhere a tag can be created:
/// the Tags screen and the client tag picker. Full parity with the old
/// tags-screen dialog (name + emoji + color swatches).
///
/// Returns the created/updated [domain.Tag] (with its id), or `null` if
/// dismissed. Non-empty name is required.
Future<domain.Tag?> showTagEditorDialog(
  BuildContext context,
  WidgetRef ref, {
  domain.Tag? existing,
  WidgetRef? pickerRef,
}) {
  final s = AppStrings.of(context);
  final nameController = TextEditingController(text: existing?.name ?? '');
  final emojiController = TextEditingController(text: existing?.emoji ?? '');
  var selectedColor = existing?.color ?? 0xFF88A36B;
  var isSaving = false;
  const colorOptions = <int>[
    0xFF88A36B, 0xFF4A6B4E, 0xFF8B6F3E, 0xFF8B4A3E,
    0xFF64B5F6, 0xFFFFB74D, 0xFFE57373, 0xFFAB47BC,
  ];

  return showDialog<domain.Tag>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) {
        final t = context.tones;
        return AlertDialog(
          title: Text(existing == null ? s.newTag : s.editTagTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: s.tagNameLabel),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: emojiController,
                decoration: InputDecoration(labelText: s.emojiOptionalLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(s.colorLabel),
                  const SizedBox(width: AppSpacing.sm),
                  ...colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? t.onSurface : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || isSaving) return;
                setDialogState(() => isSaving = true);
                final service = ref.read(tagsServiceProvider);
                final activeRef = pickerRef ?? ref;
                try {
                  if (existing == null) {
                    final id = await service.createTag(name, emoji: emojiController.text.trim(), color: selectedColor);
                    activeRef.invalidateAppData();
                    if (context.mounted) {
                      Navigator.pop(context, domain.Tag(id: id, name: name, emoji: emojiController.text.trim(), color: selectedColor));
                    }
                  } else {
                    await service.updateTag(existing.id!, name, emoji: emojiController.text.trim(), color: selectedColor);
                    activeRef.invalidateAppData();
                    if (context.mounted) {
                      Navigator.pop(context, domain.Tag(id: existing.id!, name: name, emoji: emojiController.text.trim(), color: selectedColor));
                    }
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
                  }
                }
              },
              child: Text(existing == null ? s.addTag : s.save),
            ),
          ],
        );
      },
    ),
  );
}