import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  int _selectedColor = 0xFF88A36B;
  final List<int> _colorOptions = const [
    0xFF88A36B,
    0xFF4A6B4E,
    0xFF8B6F3E,
    0xFF8B4A3E,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFE57373,
    0xFFAB47BC,
  ];

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('برچسب‌ها')),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (tags) {
          if (tags.isEmpty) {
            return const AppEmptyState(icon: Icons.label_outline, title: 'برچسبی تعریف نشده', subtitle: 'برای سازماندهی مشتریان برچسب ایجاد کنید');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return FutureBuilder<int>(
                future: ref.read(tagsServiceProvider).countClientsWithTag(tag.id!),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(tag.color),
                        child: Text(tag.emoji.isNotEmpty ? tag.emoji : tag.name[0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(tag.name, style: AppTypography.bodyLarge),
                      subtitle: Text('$count مشتری', style: AppTypography.bodySmall),
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
                                  title: const Text('حذف برچسب'),
                                  content: Text('آیا از حذف "${tag.name}" اطمینان دارید؟'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر')),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('بله')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(tagsServiceProvider).deleteTag(tag.id!);
                                ref.invalidate(allTagsProvider);
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('برچسب جدید'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    _nameController.clear();
    _emojiController.clear();
    _selectedColor = _colorOptions.first;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('برچسب جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام برچسب'),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _emojiController,
                decoration: const InputDecoration(labelText: 'ایموجی (اختیاری)'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Text('رنگ: '),
                  const SizedBox(width: AppSpacing.sm),
                  ..._colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color ? AppColors.onSurface : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                await ref.read(tagsServiceProvider).createTag(_nameController.text.trim(), emoji: _emojiController.text.trim(), color: _selectedColor);
                ref.invalidate(allTagsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic tag) {
    _nameController.text = tag.name;
    _emojiController.text = tag.emoji;
    _selectedColor = tag.color;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ویرایش برچسب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام برچسب'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _emojiController,
                decoration: const InputDecoration(labelText: 'ایموجی (اختیاری)'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Text('رنگ: '),
                  const SizedBox(width: AppSpacing.sm),
                  ..._colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color ? AppColors.onSurface : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                await ref.read(tagsServiceProvider).updateTag(tag.id!, _nameController.text.trim(), emoji: _emojiController.text.trim(), color: _selectedColor);
                ref.invalidate(allTagsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
