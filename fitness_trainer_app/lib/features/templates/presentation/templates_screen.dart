import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('قالب‌های برنامه')),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (templates) {
          if (templates.isEmpty) {
            return const AppEmptyState(icon: Icons.fitness_center, title: 'قالبی تعریف نشده', subtitle: 'برای شروع اولین قالب را ایجاد کنید');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return FutureBuilder<int>(
                future: ref.read(templatesServiceProvider).countPlansUsingTemplate(template.id!),
                builder: (context, snapshot) {
                  final usageCount = snapshot.data ?? 0;
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(template.name, style: AppTypography.headlineMedium),
                            ),
                            if (usageCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                                ),
                                child: Text('$usageCount مورد استفاده', style: AppTypography.labelMedium),
                              ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '${AppRoutes.editTemplate}/${template.id}');
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('حذف قالب'),
                                    content: Text('آیا از حذف "${template.name}" اطمینان دارید؟'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('خیر')),
                                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('بله')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(templatesServiceProvider).deleteTemplate(template.id!);
                                  ref.invalidate(allTemplatesProvider);
                                }
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            AppPill(label: '${template.sessions} جلسه', color: AppColors.primaryLight),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(label: '${template.days} روز', color: AppColors.surfaceVariant),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(label: 'هر ${template.days ~/ template.sessions} روز یک جلسه', color: AppColors.warningSoft),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTemplate);
        },
        icon: const Icon(Icons.add),
        label: const Text('قالب جدید'),
      ),
    );
  }
}
